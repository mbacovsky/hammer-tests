require 'csv'

class Output

  def initialize(output)
    @output = output
  end

  def output
    @output || ""
  end

  def lines
    output.split("\n")
  end

end


class CsvOutput < Output

  def initialize(output)
    parse(output)
  end

  def column_titles
    @titles || []
  end

  def has_column?(name)
    column_titles.include?(name.upcase)
  end

  def column(name)
    idx = column_titles.index(name)
    return [] if idx.nil?
    @rows.map do |row|
      row[idx]
    end
  end

  private

  def parse(output)
    @titles = nil
    @rows = []
    CSV.parse(output) do |row|
      if @titles.nil?
        @titles = row
      else
        @rows << row
      end
    end
  end

end

class SimpleCsvOutput < CsvOutput

  def column(name)
    super(name)[0]
  end

end

class ListOutput < Output

  CELL_DIVIDER = '|'

  def data_lines
    lines.reject{ |line| line.strip =~ /^[|-]*$/}
  end

  def column_titles
    if data_lines.empty?
      []
    else
      data_lines[0].split(CELL_DIVIDER).collect{ |cell| cell.strip.upcase }
    end
  end

  def has_column?(name)
    column_titles.include?(name.upcase)
  end

end

class ShowOutput < Output

  def initialize(output)
    parse(output)
  end

  def has_column?(name)
    column_titles.include?(name)
  end

  def column_titles
    @content.keys
  end

  def column(name)
    @content[name]
  end

  def parse(output)
    @content = {}
    last_title = nil

    output.split("\n").each do |line|
      if line.start_with?(" ")
        @content[last_title] << "\n" unless @content[last_title].empty?
        @content[last_title] << line.strip
      else
        title, *rest = line.split(":")
        value = rest.join(":")
        last_title = title.to_s.strip
        @content[last_title] = value.strip
      end
    end
  end

end
