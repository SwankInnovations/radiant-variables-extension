module Variables
  module Evaluator

    include ConditionalTags::Evaluatable

    evaluator "vars", :index_required do |tag, element_info|
      current_vars = (tag.globals.vars ||= {}).merge(Variables.contextual_vars(tag))
      unless element_info[:index] == '*show all*'
        current_vars[element_info[:index]]
      else
        output = "Current Variables:"
        if current_vars.empty?
          output << " none"
        else
          current_vars.sort.each do |name, value|
            output << "\n  #{name} = #{value.inspect}"
          end
          output << "\n"
        end
        output
      end
    end

  end
end