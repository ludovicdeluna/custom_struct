# Only for making simple tests in a sandbox
begin
  Object.send(:remove_const, :Ludo)
  GC.start
rescue
  puts 'First loading of Ludo'
end

def reloadme
  load 'custom_struct.rb'
end

def newtest
  test = Ludo::Scope.new
  test.cities.values = ["New York", "Paris", "Berlin"]
  test.cities << "Chicago"
  test.publishers = [10, 25, "IKE"]
  test.sizes = ["115x205", "44x152", {height: 10, width: 100}]
  test.sizes << "18x15"
  return test
end


# And now, the module. Use what you want in your code.
module Ludo

  class SizeList < Array
    def initialize(*args)
      args.flatten.each {|size| self << size }
    end

    def <<(values)
      if values.is_a? Hash
        values = FilterList.stringkey values
        super( Dimension.new values['width'], values['height'] )
      elsif values.is_a? String
        values = values.split('x')
        super( Dimension.new values[0], values[1] )
      end
    end

    def to_h
      self.map{|size| size.to_h }
    end
  end

  class Dimension < (Struct.new :width, :height)
    def initialize(*args)
      self.width = args[0]
      self.height = args[1]
    end

    def width=(value)
      value ||= 0
      self[:width] = value.to_s
    end

    def height=(value)
      value ||= 0
      self[:height] = value.to_s
    end
  end

  class FilterList < (Struct.new :include, :values)
    def initialize(args = nil)
      if args.nil?
        self.include = nil
        self.values = nil
        return self
      end

      args = args.is_a?(Hash) ? FilterList.stringkey(args) : {'values' => args}
      self.include = args['include']
      self.values = args['values']
    end

    def include=(boolean)
      boolean = true if boolean.nil?
      self[:include] = [true, 'true', 1].include? boolean
    end

    def values=(arr)
      arr ||= []
      self[:values] = arr.is_a?(Array) ? arr : [arr]
    end

    def <<(value)
      self[:values] << value.to_s
    end

    alias_method :push, :<<

    def pop
      self.values.pop
    end

    def self.stringkey(hsh)
      hsh.map {|h| [ h[0].to_s, h[1] ] }.to_h
    end

  end

  require 'json'
  class Scope < (Struct.new :cities, :publishers, :sizes)
    def initialize(hsh = {})
      hsh = hsh.map {|h| [ h[0].to_s, h[1] ] }.to_h
      self.members.each do |key|
        self.send "#{key}=".to_sym, hsh[key.to_s]
      end
    end

    def cities=(list)
      self[:cities] = list.is_a?(FilterList) ? list : FilterList.new(list)
    end

    def sizes=(sizes)
      self[:sizes] = sizes.is_a?(SizeList) ? sizes : SizeList.new(sizes)
    end

    def publishers=(arr)
      if arr.is_a? Array
        arr = arr.map{|value| value.to_s}
      else
        arr = [arr.to_s]
      end
      self[:publishers] = arr
    end

    def to_h
      self.members.map{|key|
        objtype = self[key].class
        [ key,
          (objtype == Array && objtype != SizeList) ? self[key] : self[key].to_h
        ]
      }.to_h
    end

    def pp
      puts(JSON.pretty_generate self.to_h)
    end

  end
end
