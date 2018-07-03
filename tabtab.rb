module Tabtab
  @@prev_c_arr = []
  def swallow_whitespace str
    if !(peek_char(str) =~ /\t/)
      return str
    end
    str.shift
    trampoline { swallow_whitespace(str) }
    return str
  end

  def previous_char
    return @@prev_c_arr[-2]
  end

  def peek_char str
    q = str.shift
    str.unshift q
    q
  end
  def get_char str
    q = str.shift
    @@prev_c_arr << q
    return q
  end
  
  def test_table
    <<~TABULA
    !
    hello	my		friend
    salve	meus	amicus
    greet.2sg.imp	.1sg.poss	friend:nom.sg
    !
    TABULA
  end
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

  def build_table(str)
    if void? str then raise "Can't build an empty table" end
    raise "Missing start '!' in declaration" unless str[0] == '!'
    result = table_start + build_row(str.chomp[2..-2]) + table_end
    targets = mark_points(result)
    add_sc(result, targets)
  end

  def table_end
    s = <<~TABULA
  \n|}
  TABULA
    s.chomp
  end

  def table_start
    s = <<~TABULA
  {|class="table"\n
  TABULA
    s.chomp
  end
  
  def void?(str)
    if str.nil? | str.empty? then return true end
  end

  def build_row(str)
    if void? str then raise "Can't build an empty row" end
    arr = str.chars
    row = __build_row(arr, nil)
  end

  def __build_row (charr, acc)
    if charr == [] then return acc end
    if acc == nil then acc = "|"  end

    ch = charr.shift
    case ch
    when /\t/
      charr = swallow_whitespace(charr)
      acc += "||"
    when /\n/
      if peek_char(charr) != nil
        acc += "\n|-\n|"
      end
    when /\S/i
      acc += ch
    end

    trampoline { __build_row(charr, acc) }
    
  end
  
  def mark_points str
    arr = str.chars
    trampoline { __mark_points(arr, nil, []) }
  end

  def add_sc(str, pts)
#    puts "Inserting small caps..."
    prefix_insert(str.chars, pts, '{{sc|', '}}', 0)
  end
  
  def prefix_insert(arr, points, obj, obj2, offset)
    if points == [] then return arr.reduce(:+).to_s end
    case arr
    when String
      arr = arr.chars
    end
  #  puts "Called, offset is #{offset}"

    if (points.count.even?)
 #     puts "Even!"
      i = points.shift
      arr.insert(i+offset, obj)
      offset += 1
    else
      i = points.shift
      arr.insert(i+offset, obj2)
      offset += 1
   #   puts "i: #{i}, of: #{offset} -> #{i+offset}"
    end
    trampoline { prefix_insert(arr,points, obj, obj2, offset) }
  end


  def __mark_points(arr, ctr, result)
    if arr == [] then return result end
    if ctr == nil
      ctr = 0
    end
    
    ch = arr.shift
    case ch
    when ':'
      if (result.count.even?)
        result << ctr
      end
    when '.'
      if (result.count.even?)
        result << ctr
      end
    when '|'
      if (result.count.odd?)
        result << ctr
      end
    when /\t/
      if (result.count.odd?)
        result << ctr        
      end
    when /\n/
      if (result.count.odd?)
        result << ctr
      end

    end

    ctr += 1
    __mark_points(arr, ctr, result)
  end

end
