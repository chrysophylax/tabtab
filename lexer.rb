module Tabtab
  class Lexer
    attr_reader :seen, :input, :output, :ir
      TABLE_START = '{|class="table"'
      TABLE_END = '|}'

    def trampoline
      f = yield
      loop do
        case f
        when Proc
          f = f[]
        else
          break f
        end
      end
    end    

    def initialize
      @seen = []
      @output = []
      @input = []
      @ir = []
    end

    def feed(str)
      @input = str
      return self
    end
    
    def invoke
      @ir = @input.chars
      @output = build_row(@ir)

    end

    def to_s
      return @output.to_s
    end

    def get_char(charr)
      ch = charr.shift
      @seen << ch
      return ch
    end
    
    def peek_char(charr)
      ch = charr.shift
      charr.unshift(ch)
      return ch
    end

    def prev_char
      return @seen[-2]
    end

    def consume_ws(charr)
      next_ch = peek_char(charr)
      
      if (next_ch != '\t')
        return charr
      end
      charr.shift
      trampoline { consume_ws(charr) }
    end

    def void?(str)
      if str.nil? | str.empty? then return true end
    end

    def build_table(charr)        
      ch = get_char(charr)
      raise "Missing start declaration '!' for table." unless ch == '!'
      raise "Missing end declaration '!' for table." unless
        charr[-1] == '!'

      result = build_row(charr)
      return result.to_s
    end

    def build_row(arr)
      if void? arr then raise "Can't build an empty row" end
      row = __build_row(arr, nil)
    end

    def handle_table_declarator(read, arr)
      # consume the whitespace
      ch = arr.shift
      if prev_char == nil
        #beginning of a table-def
        #add first-row marker after \n
        raise "Table declaration missing newline" unless ch =~ /\s/
        return TABLE_START + "\n|"

      elsif peek_char(arr) == nil
        #end of a table-def
        return "\n" + TABLE_END
      end
      
    end

    def handle_column_data(ch, arr)
      #TODO check for small_caps and other funky functions
      return ch
    end

    def handle_column_separator(ch, arr)
      arr = consume_ws(arr)
      return "||"
    end

    def handle_newline(ch, arr)
      if peek_char(arr) == '!'
      #skip writin \n at end of table-def
        ""
      elsif peek_char(arr) != nil
        "\n|-\n|"
      end
    end

    def __build_row (charr, acc)
      if charr == [] then return acc end
      if acc == nil then acc = ""  end

      ch = get_char(charr)
      case ch
      when '!'
        acc += handle_table_declarator(ch, charr)
      when "\t"
        acc += handle_row_separator(ch, charr)
      when "\n"
        acc += handle_newline(ch, charr)
      when /\S/i
        acc += handle_column_data(ch, charr)
      end

      trampoline { __build_row(charr, acc) }
      
    end
  end

end
