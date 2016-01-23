#
# NOTE:
# Props To a2800276 (tim@kuriositaet.de) for the original Hexy Gem
# This code is a fork of Hexy modified for html output.
#
module Snorby

  class Payload

    def initialize bytes, config = {}
      @bytes     = bytes
      @width     = config[:width] || 16
      @numbering = config[:numbering] == :none  ? :none : :hex_bytes
      @format = case config[:format]
                when :none, :fours
                  config[:format]
                else
                  :twos
                end
      @new_lines = config[:new_lines] || false
      @case      = config[:case]      == :upper ? :upper: :lower
      @annotate  = config[:annotate]  == :none  ? :none : :ascii
      @prefix    = config[:prefix]    ||= ""
      @indent    = config[:indent]    ||= 0
      @html = config[:html] || false
      @ascii = config[:ascii] || false
      1.upto(@indent) { @prefix += " " }
    end

    def to_s
      str = ""
      0.step(@bytes.length, @width) {|i|
        string = @bytes[i,@width]

        # p string
        # string.gsub!(/\020/, " ")

        hex = string.unpack("H*")[0]
        hex.upcase! if @case == :upper


        if @format == :fours
          hex.gsub!(/(.{4})/) {|m|
            m+" " unless @ascii
          }
        elsif @format == :twos
          hex.sub!(/(.{#{@width}})/) { |m|
                                       m+"  " unless @ascii
          }
          hex.gsub!(/(\S\S)/) { |m|
            m+" " unless @ascii
          }
        end

        if @new_lines
          string.gsub!(/[\x0a]/, ".")
          string.gsub!(Regexp.new("[\040\177-\377]", nil, "n"), '.')
        else
          string.gsub!(Regexp.new("[\000-\040\177-\377]", nil, "n"), ".")
        end

        len = case @format
              when :fours
                (@width*2)+(@width/2)
              when :twos
                (@width * 3)+2
              else
                @width *2
              end

        str << @prefix

        if @html
          str << "<span class='payload-number'>%07X:</span> " % (i) if @numbering == :hex_bytes
          str << "<span class='payload-hex'>#{CGI::escapeHTML(("%-#{len}s" % hex))}</span>"
          str << " <span class='payload-ascii'>#{CGI::escapeHTML(string)}</span>" if @annotate == :ascii
          str << "\n"
        elsif @ascii
          str << string
        else
          str << "%07X: " % (i) if @numbering == :hex_bytes
          str << ("%-#{len}s" % hex)
          str << " #{string}" if @annotate == :ascii
          str << "\n"
        end

      }
      str << "\n"
      return "<span class='payload-ascii'>#{CGI::escapeHTML(str)}</span>" if @ascii
      str
    end
  end

end
