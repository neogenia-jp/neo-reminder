require "csv"
module Util
  class CsvFormatter
    attr_accessor :result

    # SQL文字列 -> CSV
    def self.from_sql(sql)
      result = ActiveRecord::Base.connection.select_all(sql)
      from_sql_result(result)
    end

    # SQLファイル -> CSV
    def self.from_sql_file(sql_file_path)
      sql_str = File.read(sql_file_path)
      result = ActiveRecord::Base.connection.select_all(sql_str)
      from_sql_result(result)
    end

    # SQL実行結果 -> CSV
    def self.from_sql_result(result)
      CsvFormatter.new(result)
    end

    # Windows31J に変換できない文字列を事前に変換する
    def str_to_windows31j_safety(str)
      return str unless str.is_a? String
      from_chr = "\u{301C 2212 00A2 00A3 00AC 2013 2014 2016 203E 00A0 00F8 203A}"
      to_chr   = "\u{FF5E FF0D FFE0 FFE1 FFE2 FF0D 2015 2225 FFE3 0020 03A6 3009}"
      str.tr(from_chr, to_chr)
    end

    # 文字列化
    def to_s
      CSV.generate(encoding: @encoding, row_sep: @lines_terminated_by) do |csv|
        each_line { |row| csv << row.map {|str| str_to_windows31j_safety(str)} }
      end
    end

    # ファイル化
    def to_file(filepath)
      CSV.open(filepath, "w", encoding: @encoding, row_sep: @lines_terminated_by) do |csv|
        each_line { |row| csv << row.map {|str| str_to_windows31j_safety(str)} }
      end
    end

    # オプション
    def options(encoding: Encoding::CP932, lines_terminated_by: "\n", add_column_name: true)
      @encoding = encoding
      @lines_terminated_by = lines_terminated_by
      @add_column_name = add_column_name
      self
    end

    private
    def initialize(result)
      @result = result
      options
    end

    # 1行ずつ返す
    def each_line
      if @result.first.is_a? Hash
        # Hash の場合
        yield @result.first.keys if @add_column_name
        @result.each { |row| yield row.values }
      else
        # ActiveRecordの場合
        yield @result.columns if @add_column_name
        @result.rows.each { |row| yield row }
      end
    end
  end
end
