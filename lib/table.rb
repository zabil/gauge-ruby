# Copyright 2015 ThoughtWorks, Inc.

# This file is part of Gauge-Ruby.

# Gauge-Ruby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Gauge-Ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Gauge-Ruby.  If not, see <http://www.gnu.org/licenses/>.

module Gauge
  # Holds a table definition. This corresponds to a markdown table defined in the .spec files.
  # @api public
  class Table
    # @api private
    def initialize(protoTable)
      @columns = protoTable.headers.cells
      @rows = []
      protoTable.rows.each do |row|
          @rows.push row.cells
      end
    end

    # Gets the column headers of the table
    # @return [string[]]
    # @deprecated Use [] accessor instead
    def columns
      @columns
    end

    # Gets the rows of the table. The rows are two dimensional arrays.
    # @return [string[][]]
    # @deprecated Use {#[]} accessor instead
    def rows
      @rows
    end

    # Gets the table data.
    # @param index Either row index, or Column name.
    # @return [Hash] When an integer index is passed. Values correspond to a the row in the table with the index.
    # @example
    #   table[0] => {"Col1" => "Row1.Cell1", "Col2" => "Row2.Col1", ...}
    #   table[i] => nil # when index is out of range
    # @return [string[]] When a string key is passed. Values correspond to the respective cells in a row, matching the index of value in Column headers.
    # @example
    #   table["Col1"] => ["Row1.Cell1", "Row1.Cell1", ...]
    #   table["Invalid_Col_Name"] => nil
    def [](index)
      return row_values_as_hash(@rows[index]) if index.is_a?(Integer)
      column_values_as_array(index)
    end

    private
    def row_values_as_hash(row)
      row.nil? ? nil : Hash[@columns.zip(row)]
    end

    def column_values_as_array(col_name)
      i = @columns.index col_name
      i.nil? ? nil : @rows.map { |r| r[i] }
    end
  end
end
