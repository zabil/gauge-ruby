package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"runtime"
	"strings"
)

const (
	BUILD_DIR   = "tmp"
	CGO_ENABLED = "CGO_ENABLED"
)

const (
	gaugeRubyGemfile  = "gauge-ruby-*.gem"
	dotGauge          = ".gauge"
	plugins           = "plugins"
	GOARCH            = "GOARCH"
	GOOS              = "GOOS"
	X86               = "386"
	X86_64            = "amd64"
	DARWIN            = "darwin"
	LINUX             = "linux"
	WINDOWS           = "windows"
	bin               = "bin"
	newDirPermissions = 0755
	gauge             = "gauge"
	gaugeRuby         = "gauge-ruby"
	deployDir         = "deploy"
)

var BUILD_DIR_BIN = filepath.Join(BUILD_DIR, bin)
var BUILD_DIR_SRC = filepath.Join(BUILD_DIR, "src")
var BUILD_DIR_PKG = filepath.Join(BUILD_DIR, "pkg")
var BUILD_DIR_GAUGE_RUBY = filepath.Join(BUILD_DIR_SRC, gaugeRuby)
var platformBinDir = filepath.Join(bin, fmt.Sprintf("%s_%s", runtime.GOOS, runtime.GOARCH))

var gaugeRubyFiles = []string{"gauge-ruby.go"}

func isExecMode(mode os.FileMode) bool {
	return (mode & 0111) != 0
}

func mirrorFile(src, dst string) error {
	sfi, err := os.Stat(src)
	if err != nil {
		return err
	}
	if sfi.Mode()&os.ModeType != 0 {
		log.Fatalf("mirrorFile can't deal with non-regular file %s", src)
	}
	dfi, err := os.Stat(dst)
	if err == nil &&
		isExecMode(sfi.Mode()) == isExecMode(dfi.Mode()) &&
		(dfi.Mode()&os.ModeType == 0) &&
		dfi.Size() == sfi.Size() &&
		dfi.ModTime().Unix() == sfi.ModTime().Unix() {
		// Seems to not be modified.
		return nil
	}

	dstDir := filepath.Dir(dst)
	if err := os.MkdirAll(dstDir, newDirPermissions); err != nil {
		return err
	}

	df, err := os.Create(dst)
	if err != nil {
		return err
	}
	sf, err := os.Open(src)
	if err != nil {
		return err
	}
	defer sf.Close()

	n, err := io.Copy(df, sf)
	if err == nil && n != sfi.Size() {
		err = fmt.Errorf("copied wrong size for %s -> %s: copied %d; want %d", src, dst, n, sfi.Size())
	}
	cerr := df.Close()
	if err == nil {
		err = cerr
	}
	if err == nil {
		err = os.Chmod(dst, sfi.Mode())
	}
	if err == nil {
		err = os.Chtimes(dst, sfi.ModTime(), sfi.ModTime())
	}
	return err
}

func mirrorDir(src, dst string) error {
	log.Printf("Copying '%s' -> '%s'\n", src, dst)
	err := filepath.Walk(src, func(path string, fi os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if fi.IsDir() {
			return nil
		}
		suffix, err := filepath.Rel(src, path)
		if err != nil {
			return fmt.Errorf("Failed to find Rel(%q, %q): %v", src, path, err)
		}
		return mirrorFile(path, filepath.Join(dst, suffix))
	})
	return err
}

func createGoPathForBuild() {
	err := os.MkdirAll(BUILD_DIR_SRC, newDirPermissions)
	if err != nil {
		panic(err)
	}

	err = os.MkdirAll(BUILD_DIR_BIN, newDirPermissions)
	if err != nil {
		panic(err)
	}

	err = os.MkdirAll(BUILD_DIR_PKG, newDirPermissions)
	if err != nil {
		panic(err)
	}

	err = os.MkdirAll(BUILD_DIR_GAUGE_RUBY, newDirPermissions)
	if err != nil {
		panic(err)
	}
}

//Copy gauge ruby files to GOPATH
func copyGaugeRubyFilesToGoPath() {
	for _, f := range gaugeRubyFiles {
		mirrorFile(f, path.Join(BUILD_DIR_SRC, gaugeRuby, f))
	}
}

func setGoEnv() {
	absBuildDir, err := filepath.Abs(BUILD_DIR)
	if err != nil {
		panic(err)
	}
	set("GOPATH", absBuildDir)
	set("GOBIN", filepath.Join(absBuildDir, bin))
}

func set(envName, envValue string) {
	log.Printf("%s = %s\n", envName, envValue)
	err := os.Setenv(envName, envValue)
	if err != nil {
		panic(err)
	}
}

func runProcess(command string, workingdir string, arg ...string) {
	cmd := exec.Command(command, arg...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Dir = workingdir
	log.Printf("Execute %v\n", cmd.Args)
	err := cmd.Run()
	if err != nil {
		panic(err)
	}
}

func executeCommand(command string, arg ...string) (string, error) {
	cmd := exec.Command(command, arg...)
	bytes, err := cmd.Output()
	return strings.TrimSpace(fmt.Sprintf("%s", bytes)), err
}

func compileGoPackage(packageName string) {
	setGoEnv()
	runProcess("go", BUILD_DIR, "get", "-d", "./..")
	runProcess("go", BUILD_DIR, "install", "-v", packageName)
}

func copyBinaries() {
	err := os.MkdirAll(bin, newDirPermissions)
	if err != nil {
		panic(err)
	}

	err = mirrorDir(BUILD_DIR_BIN, bin)
	if err != nil {
		panic(err)
	}

	absBin, err := filepath.Abs(bin)
	if err != nil {
		panic(err)
	}
	log.Printf("Binaries are available at: %s\n", absBin)
}

// key will be the source file and value will be the target
func copyFiles(files map[string]string, installDir string) {
	for src, dst := range files {
		base := filepath.Base(src)
		installDst := filepath.Join(installDir, dst)
		log.Printf("Copying %s -> %s\n", src, installDst)
		stat, err := os.Stat(src)
		if err != nil {
			panic(err)
		}
		if stat.IsDir() {
			err = mirrorDir(src, installDst)
		} else {
			err = mirrorFile(src, filepath.Join(installDst, base))
		}
		if err != nil {
			panic(err)
		}
	}
}

func copyGaugeRubyFiles(destDir string) error {
	files := make(map[string]string)
	if runtime.GOOS == "windows" {
		files[filepath.Join(getBinDir(), "gauge-ruby.exe")] = bin
	} else {
		files[filepath.Join(getBinDir(), gaugeRuby)] = bin
	}

	files["ruby.json"] = ""
	files[filepath.Join("skel", "step_implementation.rb")] = "skel"
	files[filepath.Join("skel", "ruby.properties")] = filepath.Join("skel", "env")
	gemFile := getGemFile()
	if gemFile == "" {
		return errors.New(fmt.Sprintf("Could not find .gem file"))
	}

	files[gemFile] = ""
	copyFiles(files, destDir)
	return nil
}

func getGaugeRubyVersion() string {
	rubyRunnerProperties, err := getPluginProperties("ruby.json")
	if err != nil {
		panic(fmt.Sprintf("Failed to get gauge ruby properties file. %s", err))
	}
	return rubyRunnerProperties["version"].(string)
}

func installGaugeRubyFiles(installPath string) error {
	files := make(map[string]string)
	if runtime.GOOS == "windows" {
		files[filepath.Join(getBinDir(), "gauge-ruby.exe")] = bin
	} else {
		files[filepath.Join(getBinDir(), "gauge-ruby")] = bin
	}

	rubyRunnerProperties, err := getPluginProperties("ruby.json")

	if err != nil {
		return errors.New(fmt.Sprintf("Failed to get ruby runner properties. %s", err))
	}
	rubyRunnerRelativePath := filepath.Join(installPath, "ruby", rubyRunnerProperties["version"].(string))

	files["ruby.json"] = ""
	files[filepath.Join("skel", "step_implementation.rb")] = filepath.Join("skel")
	files[filepath.Join("skel", "ruby.properties")] = filepath.Join("skel", "env")
	gemFile := getGemFile()
	if gemFile == "" {
		return errors.New(fmt.Sprintf("Could not find .gem file"))
	}

	files[gemFile] = ""
	copyFiles(files, rubyRunnerRelativePath)
	installGaugeRubyGem()
	return nil
}

func getBinDir() string {
	if *binDir == "" {
		return platformBinDir
	}
	return path.Join(bin, *binDir)
}

func getGemFile() string {
	dir, err1 := os.Getwd()
	if err1 != nil {
		fmt.Println("Could not get working directory")
		os.Exit(1)
	}
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		fmt.Println("Could not find .gem file")
		os.Exit(1)
	} else {
		for _, file := range files {
			if filepath.Ext(filepath.Join(dir, file.Name())) == ".gem" {
				return file.Name()
			}
		}
	}
	return ""
}

func installGaugeRubyGem() {
	gemHome := getGemHome()
	if gemHome == "" {
		runProcess("gem", "install", "--user-install", gaugeRubyGemfile)
	} else {
		runProcess("gem", "install", gaugeRubyGemfile, "--install-dir", gemHome)
	}
}

func getGemHome() string {
	gemHome := os.Getenv("GEM_HOME")
	if gemHome != "" {
		return gemHome
	} else {
		return gemHomeFromRvm()
	}
}

func gemHomeFromRvm() string {
	output, err := executeCommand("rvm", "gemdir")
	if err == nil {
		return output
	}
	return ""
}

func moveOSBinaryToCurrentOSArchDirectory(targetName string) {
	destDir := path.Join(bin, fmt.Sprintf("%s_%s", runtime.GOOS, runtime.GOARCH))
	moveBinaryToDirectory(path.Base(targetName), destDir)
}

func moveBinaryToDirectory(target, destDir string) error {
	if runtime.GOOS == "windows" {
		target = target + ".exe"
	}
	srcFile := path.Join(bin, target)
	destFile := path.Join(destDir, target)
	if err := os.MkdirAll(destDir, newDirPermissions); err != nil {
		return err
	}
	if err := mirrorFile(srcFile, destFile); err != nil {
		return err
	}
	return os.Remove(srcFile)
}

func setEnv(envVariables map[string]string) {
	for k, v := range envVariables {
		os.Setenv(k, v)
	}
}

var install = flag.Bool("install", false, "Install to the specified prefix")
var pluginInstallPrefix = flag.String("plugin-prefix", "", "Specifies the prefix where gauge plugins will be installed")
var distro = flag.Bool("distro", false, "Creates distributables for gauge ruby")
var allPlatforms = flag.Bool("all-platforms", false, "Compiles or creates distributables for all platforms windows, linux, darwin both x86 and x86_64")
var binDir = flag.String("bin-dir", "", "Specifies OS_PLATFORM specific binaries to install when cross compiling")

var (
	platformEnvs = []map[string]string{
		map[string]string{GOARCH: X86, GOOS: DARWIN, CGO_ENABLED: "0"},
		map[string]string{GOARCH: X86_64, GOOS: DARWIN, CGO_ENABLED: "0"},
		map[string]string{GOARCH: X86, GOOS: LINUX, CGO_ENABLED: "0"},
		map[string]string{GOARCH: X86_64, GOOS: LINUX, CGO_ENABLED: "0"},
		map[string]string{GOARCH: X86, GOOS: WINDOWS, CGO_ENABLED: "0"},
		map[string]string{GOARCH: X86_64, GOOS: WINDOWS, CGO_ENABLED: "0"},
	}
)

func getPluginProperties(jsonPropertiesFile string) (map[string]interface{}, error) {
	pluginPropertiesJson, err := ioutil.ReadFile(jsonPropertiesFile)
	if err != nil {
		fmt.Printf("Could not read %s: %s\n", filepath.Base(jsonPropertiesFile), err)
		return nil, err
	}
	var pluginJson interface{}
	if err = json.Unmarshal([]byte(pluginPropertiesJson), &pluginJson); err != nil {
		fmt.Printf("Could not read %s: %s\n", filepath.Base(jsonPropertiesFile), err)
		return nil, err
	}
	return pluginJson.(map[string]interface{}), nil
}

func main() {
	createGoPathForBuild()
	copyGaugeRubyFilesToGoPath()
	flag.Parse()

	if *install {
		updatePluginInstallPrefix()
		installGaugeRubyFiles(*pluginInstallPrefix)
	} else if *distro {
		createGaugeDistro(*allPlatforms)
	} else {
		compileGaugeRuby()
	}
}

func compileGaugeRuby() {
	buildGaugeRubyGem()
	if *allPlatforms {
		compileGaugeRubyAcrossPlatforms()
	} else {
		compileGoPackage(gaugeRuby)
	}
	copyBinaries()
	moveOSBinaryToCurrentOSArchDirectory(gaugeRuby)
}

func createGaugeDistro(forAllPlatforms bool) {
	if forAllPlatforms {
		for _, platformEnv := range platformEnvs {
			setEnv(platformEnv)
			fmt.Printf("Creating distro for platform => OS:%s ARCH:%s \n", platformEnv[GOOS], platformEnv[GOARCH])
			createDistro()
		}
	} else {
		createDistro()
	}
}

func createDistro() {
	distroDir := filepath.Join(deployDir, fmt.Sprintf("%s-%s-%s.%s", gaugeRuby, getGaugeRubyVersion(), runtime.GOOS, getArch()))
	copyGaugeRubyFiles(distroDir)
}

func compileGaugeRubyAcrossPlatforms() {
	for _, platformEnv := range platformEnvs {
		setEnv(platformEnv)
		fmt.Printf("Compiling for platform => OS:%s ARCH:%s \n", platformEnv[GOOS], platformEnv[GOARCH])
		compileGoPackage(gaugeRuby)
	}
}

func buildGaugeRubyGem() {
	wd, err := os.Getwd()
	if err != nil {
		panic(err)

	}
	runProcess("gem", wd, "build", "gauge-ruby.gemspec")
}

func installGaugeRuby(installPrefix string) {
	copyGaugeRubyFiles(deployDir)
	rubyRunnerInstallPath := filepath.Join(installPrefix, "ruby", getGaugeRubyVersion())
	mirrorDir(deployDir, rubyRunnerInstallPath)
}

func updatePluginInstallPrefix() {
	if *pluginInstallPrefix == "" {
		if runtime.GOOS == "windows" {
			*pluginInstallPrefix = os.Getenv("APPDATA")
			if *pluginInstallPrefix == "" {
				panic(fmt.Errorf("Failed to find AppData directory"))
			}
			*pluginInstallPrefix = filepath.Join(*pluginInstallPrefix, gauge, plugins)
		} else {
			userHome := getUserHome()
			if userHome == "" {
				panic(fmt.Errorf("Failed to find User Home directory"))
			}
			*pluginInstallPrefix = filepath.Join(userHome, dotGauge, plugins)
		}
	}
}

func getUserHome() string {
	return os.Getenv("HOME")
}

func getArch() string {
	if runtime.GOARCH == X86 {
		return "x86"
	}
	return "x86_64"
}
