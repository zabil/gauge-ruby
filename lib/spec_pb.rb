# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: spec.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("spec.proto", :syntax => :proto3) do
    add_message "gauge.messages.ProtoSpec" do
      optional :specHeading, :string, 1
      repeated :items, :message, 2, "gauge.messages.ProtoItem"
      optional :isTableDriven, :bool, 3
      repeated :preHookFailures, :message, 4, "gauge.messages.ProtoHookFailure"
      repeated :postHookFailures, :message, 5, "gauge.messages.ProtoHookFailure"
      optional :fileName, :string, 6
      repeated :tags, :string, 7
      repeated :preHookMessages, :string, 8
      repeated :postHookMessages, :string, 9
      repeated :preHookMessage, :string, 10
      repeated :postHookMessage, :string, 11
      repeated :preHookScreenshots, :bytes, 12
      repeated :postHookScreenshots, :bytes, 13
      optional :itemCount, :int64, 14
      repeated :preHookScreenshotFiles, :string, 15
      repeated :postHookScreenshotFiles, :string, 16
    end
    add_message "gauge.messages.ProtoItem" do
      optional :itemType, :enum, 1, "gauge.messages.ProtoItem.ItemType"
      optional :step, :message, 2, "gauge.messages.ProtoStep"
      optional :concept, :message, 3, "gauge.messages.ProtoConcept"
      optional :scenario, :message, 4, "gauge.messages.ProtoScenario"
      optional :tableDrivenScenario, :message, 5, "gauge.messages.ProtoTableDrivenScenario"
      optional :comment, :message, 6, "gauge.messages.ProtoComment"
      optional :table, :message, 7, "gauge.messages.ProtoTable"
      optional :tags, :message, 8, "gauge.messages.ProtoTags"
      optional :fileName, :string, 9
    end
    add_enum "gauge.messages.ProtoItem.ItemType" do
      value :Step, 0
      value :Comment, 1
      value :Concept, 2
      value :Scenario, 3
      value :TableDrivenScenario, 4
      value :Table, 5
      value :Tags, 6
    end
    add_message "gauge.messages.ProtoScenario" do
      optional :scenarioHeading, :string, 1
      optional :failed, :bool, 2
      repeated :contexts, :message, 3, "gauge.messages.ProtoItem"
      repeated :scenarioItems, :message, 4, "gauge.messages.ProtoItem"
      optional :preHookFailure, :message, 5, "gauge.messages.ProtoHookFailure"
      optional :postHookFailure, :message, 6, "gauge.messages.ProtoHookFailure"
      repeated :tags, :string, 7
      optional :executionTime, :int64, 8
      optional :skipped, :bool, 9
      repeated :skipErrors, :string, 10
      optional :ID, :string, 11
      repeated :tearDownSteps, :message, 12, "gauge.messages.ProtoItem"
      optional :span, :message, 13, "gauge.messages.Span"
      optional :executionStatus, :enum, 14, "gauge.messages.ExecutionStatus"
      repeated :preHookMessages, :string, 15
      repeated :postHookMessages, :string, 16
      repeated :preHookMessage, :string, 17
      repeated :postHookMessage, :string, 18
      repeated :preHookScreenshots, :bytes, 19
      repeated :postHookScreenshots, :bytes, 20
      repeated :preHookScreenshotFiles, :string, 21
      repeated :postHookScreenshotFiles, :string, 22
    end
    add_message "gauge.messages.Span" do
      optional :start, :int64, 1
      optional :end, :int64, 2
      optional :startChar, :int64, 3
      optional :endChar, :int64, 4
    end
    add_message "gauge.messages.ProtoTableDrivenScenario" do
      optional :scenario, :message, 1, "gauge.messages.ProtoScenario"
      optional :tableRowIndex, :int32, 2
      optional :scenarioTableRowIndex, :int32, 3
      optional :isSpecTableDriven, :bool, 4
      optional :isScenarioTableDriven, :bool, 5
      optional :scenarioDataTable, :message, 6, "gauge.messages.ProtoTable"
      optional :scenarioTableRow, :message, 7, "gauge.messages.ProtoTable"
    end
    add_message "gauge.messages.ProtoStep" do
      optional :actualText, :string, 1
      optional :parsedText, :string, 2
      repeated :fragments, :message, 3, "gauge.messages.Fragment"
      optional :stepExecutionResult, :message, 4, "gauge.messages.ProtoStepExecutionResult"
      repeated :preHookMessages, :string, 5
      repeated :postHookMessages, :string, 6
      repeated :preHookScreenshots, :bytes, 7
      repeated :postHookScreenshots, :bytes, 8
      repeated :preHookScreenshotFiles, :string, 9
      repeated :postHookScreenshotFiles, :string, 10
    end
    add_message "gauge.messages.ProtoConcept" do
      optional :conceptStep, :message, 1, "gauge.messages.ProtoStep"
      repeated :steps, :message, 2, "gauge.messages.ProtoItem"
      optional :conceptExecutionResult, :message, 3, "gauge.messages.ProtoStepExecutionResult"
    end
    add_message "gauge.messages.ProtoTags" do
      repeated :tags, :string, 1
    end
    add_message "gauge.messages.Fragment" do
      optional :fragmentType, :enum, 1, "gauge.messages.Fragment.FragmentType"
      optional :text, :string, 2
      optional :parameter, :message, 3, "gauge.messages.Parameter"
    end
    add_enum "gauge.messages.Fragment.FragmentType" do
      value :Text, 0
      value :Parameter, 1
    end
    add_message "gauge.messages.Parameter" do
      optional :parameterType, :enum, 1, "gauge.messages.Parameter.ParameterType"
      optional :value, :string, 2
      optional :name, :string, 3
      optional :table, :message, 4, "gauge.messages.ProtoTable"
    end
    add_enum "gauge.messages.Parameter.ParameterType" do
      value :Static, 0
      value :Dynamic, 1
      value :Special_String, 2
      value :Special_Table, 3
      value :Table, 4
    end
    add_message "gauge.messages.ProtoComment" do
      optional :text, :string, 1
    end
    add_message "gauge.messages.ProtoTable" do
      optional :headers, :message, 1, "gauge.messages.ProtoTableRow"
      repeated :rows, :message, 2, "gauge.messages.ProtoTableRow"
    end
    add_message "gauge.messages.ProtoTableRow" do
      repeated :cells, :string, 1
    end
    add_message "gauge.messages.ProtoStepExecutionResult" do
      optional :executionResult, :message, 1, "gauge.messages.ProtoExecutionResult"
      optional :preHookFailure, :message, 2, "gauge.messages.ProtoHookFailure"
      optional :postHookFailure, :message, 3, "gauge.messages.ProtoHookFailure"
      optional :skipped, :bool, 4
      optional :skippedReason, :string, 5
    end
    add_message "gauge.messages.ProtoExecutionResult" do
      optional :failed, :bool, 1
      optional :recoverableError, :bool, 2
      optional :errorMessage, :string, 3
      optional :stackTrace, :string, 4
      optional :screenShot, :bytes, 5
      optional :executionTime, :int64, 6
      repeated :message, :string, 7
      optional :errorType, :enum, 8, "gauge.messages.ProtoExecutionResult.ErrorType"
      optional :failureScreenshot, :bytes, 9
      repeated :screenshots, :bytes, 10
      optional :failureScreenshotFile, :string, 11
      repeated :screenshotFiles, :string, 12
    end
    add_enum "gauge.messages.ProtoExecutionResult.ErrorType" do
      value :ASSERTION, 0
      value :VERIFICATION, 1
    end
    add_message "gauge.messages.ProtoHookFailure" do
      optional :stackTrace, :string, 1
      optional :errorMessage, :string, 2
      optional :screenShot, :bytes, 3
      optional :tableRowIndex, :int32, 4
      optional :failureScreenshot, :bytes, 5
      optional :failureScreenshotFile, :string, 6
    end
    add_message "gauge.messages.ProtoSuiteResult" do
      repeated :specResults, :message, 1, "gauge.messages.ProtoSpecResult"
      optional :preHookFailure, :message, 2, "gauge.messages.ProtoHookFailure"
      optional :postHookFailure, :message, 3, "gauge.messages.ProtoHookFailure"
      optional :failed, :bool, 4
      optional :specsFailedCount, :int32, 5
      optional :executionTime, :int64, 6
      optional :successRate, :float, 7
      optional :environment, :string, 8
      optional :tags, :string, 9
      optional :projectName, :string, 10
      optional :timestamp, :string, 11
      optional :specsSkippedCount, :int32, 12
      repeated :preHookMessages, :string, 13
      repeated :postHookMessages, :string, 14
      repeated :preHookMessage, :string, 15
      repeated :postHookMessage, :string, 16
      repeated :preHookScreenshots, :bytes, 17
      repeated :postHookScreenshots, :bytes, 18
      optional :chunked, :bool, 19
      optional :chunkSize, :int64, 20
      repeated :preHookScreenshotFiles, :string, 21
      repeated :postHookScreenshotFiles, :string, 22
    end
    add_message "gauge.messages.ProtoSpecResult" do
      optional :protoSpec, :message, 1, "gauge.messages.ProtoSpec"
      optional :scenarioCount, :int32, 2
      optional :scenarioFailedCount, :int32, 3
      optional :failed, :bool, 4
      repeated :failedDataTableRows, :int32, 5
      optional :executionTime, :int64, 6
      optional :skipped, :bool, 7
      optional :scenarioSkippedCount, :int32, 8
      repeated :skippedDataTableRows, :int32, 9
      repeated :errors, :message, 10, "gauge.messages.Error"
      optional :timestamp, :string, 11
    end
    add_message "gauge.messages.ProtoScenarioResult" do
      optional :protoItem, :message, 1, "gauge.messages.ProtoItem"
      optional :executionTime, :int64, 2
      optional :timestamp, :string, 3
    end
    add_message "gauge.messages.ProtoStepResult" do
      optional :protoItem, :message, 1, "gauge.messages.ProtoItem"
      optional :executionTime, :int64, 2
      optional :timestamp, :string, 3
    end
    add_message "gauge.messages.Error" do
      optional :type, :enum, 1, "gauge.messages.Error.ErrorType"
      optional :filename, :string, 2
      optional :lineNumber, :int32, 3
      optional :message, :string, 4
    end
    add_enum "gauge.messages.Error.ErrorType" do
      value :PARSE_ERROR, 0
      value :VALIDATION_ERROR, 1
    end
    add_message "gauge.messages.ProtoStepValue" do
      optional :stepValue, :string, 1
      optional :parameterizedStepValue, :string, 2
      repeated :parameters, :string, 3
    end
    add_enum "gauge.messages.ExecutionStatus" do
      value :NOTEXECUTED, 0
      value :PASSED, 1
      value :FAILED, 2
      value :SKIPPED, 3
    end
  end
end

module Gauge
  module Messages
    ProtoSpec = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoSpec").msgclass
    ProtoItem = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoItem").msgclass
    ProtoItem::ItemType = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoItem.ItemType").enummodule
    ProtoScenario = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoScenario").msgclass
    Span = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Span").msgclass
    ProtoTableDrivenScenario = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoTableDrivenScenario").msgclass
    ProtoStep = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoStep").msgclass
    ProtoConcept = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoConcept").msgclass
    ProtoTags = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoTags").msgclass
    Fragment = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Fragment").msgclass
    Fragment::FragmentType = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Fragment.FragmentType").enummodule
    Parameter = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Parameter").msgclass
    Parameter::ParameterType = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Parameter.ParameterType").enummodule
    ProtoComment = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoComment").msgclass
    ProtoTable = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoTable").msgclass
    ProtoTableRow = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoTableRow").msgclass
    ProtoStepExecutionResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoStepExecutionResult").msgclass
    ProtoExecutionResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoExecutionResult").msgclass
    ProtoExecutionResult::ErrorType = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoExecutionResult.ErrorType").enummodule
    ProtoHookFailure = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoHookFailure").msgclass
    ProtoSuiteResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoSuiteResult").msgclass
    ProtoSpecResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoSpecResult").msgclass
    ProtoScenarioResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoScenarioResult").msgclass
    ProtoStepResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoStepResult").msgclass
    Error = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Error").msgclass
    Error::ErrorType = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.Error.ErrorType").enummodule
    ProtoStepValue = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ProtoStepValue").msgclass
    ExecutionStatus = Google::Protobuf::DescriptorPool.generated_pool.lookup("gauge.messages.ExecutionStatus").enummodule
  end
end
