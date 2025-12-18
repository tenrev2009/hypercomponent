# frozen_string_literal: true

require_relative '../data/storage'
require_relative '../expressions/compilation_cache'
require_relative '../expressions/evaluator'
require_relative '../diagnostics/logger'

module HyperComponents
  module Rules
    module AutomationEngine
      def self.apply!(definition, value_store, rules, ctx)
        return if rules.nil? || rules.empty?

        evaluator = Expressions::Evaluator.new(lambda do |obj, param|
          # Resolve param value from the appropriate instance store if obj differs
          if obj == ctx[:self]
            value_store.get(param)
          else
            # ADAPTATION STORAGE v2
            begin
              # On récupère les données via la nouvelle méthode read()
              # Note: read() renvoie déjà les valeurs par défaut fusionnées (meta, features, etc.)
              instance_data = Data::Storage.read(obj)
              
              # Dans le nouveau modèle, il n'y a pas forcément de payload séparé pour la définition
              # car read() fait le travail de fusion. On passe un hash vide pour def_payload.
              def_payload = {} 
              
              # On initialise un ValueStore temporaire pour l'autre objet
              vs = Params::ValueStore.new(def_payload, instance_data)
              vs.get(param)
            rescue => e
              Diagnostics::Logger.debug("[HC][Automation] Resolution error for #{param}: #{e.message}")
              nil
            end
          end
        end)

        rules.each do |rule|
          cond = rule['when']
          ok = true
          if cond && !cond.to_s.strip.empty?
            ast = Expressions::CompilationCache.compile(definition, cond)
            ok = !!evaluator.eval(ast, ctx)
          end
          next unless ok
          (rule['then'] || []).each do |act|
            case act['action']
            when 'set'
              target = act['param']
              expr = act['expr']
              ast = Expressions::CompilationCache.compile(definition, expr)
              v = evaluator.eval(ast, ctx)
              value_store.set_override(target, v)
            when 'warn'
              Diagnostics::Logger.warn("[HC][RULE] #{act['message']}")
            when 'error'
              raise RuntimeError, act['message'].to_s
            end
          end
        end
      end
    end
  end
end