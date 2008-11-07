module Variables
  module Evaluator

    include ConditionalTags::Evaluatable

    evaluator "vars", :index_required do |tag, element_info|
      current_vars = (tag.globals.vars ||= {}).merge(Variables.contextual_vars(tag))
      current_vars[element_info[:index]]
    end

  end
end