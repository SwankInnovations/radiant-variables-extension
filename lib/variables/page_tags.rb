module Variables

  def self.contextual_vars(tag)
    var_attrs = {}
    tag.context.instance_variable_get(:@tag_binding_stack).each do |tag_binding|
      case tag_binding.name
        when 'snippet'
          var_attrs.merge!(tag_binding.attr.except('name'))
        when 'content'
          var_attrs.merge!(tag_binding.attr.except('part', 'inherit', 'contextual'))
      end
    end
    cast_variables(var_attrs)
  end


  def self.cast_variables(attr)
    vars = {}
    attr.each do |key, value|
      stripped_value = value.strip
      case stripped_value.downcase
        when "false"
          vars[key] = false
        when "true"
          vars[key] = true
        when "nil", "null", "nothing"
          vars[key] = nil
        else
          # try to make it a number (otherwise it's a string)
          if (Float(stripped_value) rescue false)
            vars[key] = stripped_value.to_f
          # see if it's a string wrapped in '
          elsif stripped_value =~ /^"((?:[^"]|"")*)"$/
            vars[key] = $1.gsub('""', '"')
          # see if it's a string wrapped in "
          elsif stripped_value =~ /^'((?:[^']|'')*)'$/
            vars[key] = $1.gsub("''", "'")
          # must be a plain ol' string
          else
            vars[key] = value
          end
      end
    end
    vars
  end


  module PageTags

    include Radiant::Taggable
    class TagError < StandardError; end


    desc %{
      Stores values for later use. Each attribute used defines the name and value
       (i.e. <code>a="15"</code> would store the number "15" under the name "a").

      When setting each variable, the tag identifies each value as one of:

       * number
       * true/false (boolean)
       * nothing
       * text (default if not one of the above)

      Note: You can force the variable to be text by wrapping it in single or double
      quotes (i.e.  <code>myVar="'15'"</code>)

      *Usage:*
      <pre><code><r:set_vars varName="varValue" [varName2="varValue2" ...]/></code></pre>
    }
    tag 'set_vars' do |tag|
      unless tag.attr.empty?
        tag.globals.vars ||= {}
        tag.globals.vars.merge!(Variables.cast_variables(tag.attr))
        return ""
    else
        raise TagError.new("`set_vars' tag must be given at least one attribute")
      end
    end


    desc %{
      Renders the value of a variable. The @value_for@ attribute specifies
      which variable (or, you can use <code>value_for="*all*"</code> to
      render a list of all current variables).

      *Usage:*
      <pre><code><r:puts value_for="varName|*all*" /></code></pre>
    }
    tag 'puts' do |tag|
      if var_name = tag.attr['value_for']
        current_vars = (tag.globals.vars ||= {}).merge(Variables.contextual_vars(tag))
        if var_name == '*all*'
          output = "Current Variables:"
          if current_vars.empty?
            output << " none"
          else
            current_vars.sort.each do |name, value|
              output << "\n  #{name} = #{value.inspect}"
            end
            output << "\n"
          end
        else
          current_vars[var_name].to_s
        end
      else
        raise TagError.new("`puts' tag must contain a 'value_for' attribute")
      end
    end

  end
end