module Tabtab
  class Lexer
    attr_reader :seen, :input, :output, :ir

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

    def prev_char(charr)
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

      result = '{|class="table"' + build_row(charr)
      + "|}"
      return result.to_s
    end

    def build_row(arr)
      if void? arr then raise "Can't build an empty row" end
      row = __build_row(arr, nil)
    end

    def __build_row (charr, acc)
      if charr == [] then return acc end
      if acc == nil then acc = "|"  end

      ch = get_char(charr)
      case ch
      when '!'
        if peek_char(charr) =~ /\s/
          acc += '{|class="table"'
          acc += "\n"
        elsif peek_char(charr) == nil
          acc += '|}'
        end
      when "\t"
        charr = consume_ws(charr)
        acc += "||"
      when "\n"
        if peek_char(charr) != nil
          acc += "\n|-\n|"
        end
      when /\S/i
        acc += ch
      end

      trampoline { __build_row(charr, acc) }
      
    end
  end

end
