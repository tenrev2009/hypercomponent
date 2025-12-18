# frozen_string_literal: true

require "sketchup.rb"
require "json"

module HyperComponents
  module UI
    class DialogController
      TITLE    = "HyperComponents"
      PREF_KEY = "HyperComponents.Dialog"

      class << self
        def install_menu!
          menu = ::UI.menu("Plugins")
          menu.add_separator
          menu.add_item("HyperComponents: Panel") { show }
        end

        # --- AJOUT: Méthodes requises par Lifecycle et Observers ---
        
        def ensure_singleton!
          # Méthode requise par le cycle de vie.
          # Le dialogue est créé à la demande, donc rien à faire ici pour l'instant.
        end

        def refresh_if_open
          # Rafraîchir la sélection si le dialogue est visible
          notify_selection(selected_entity) if @dlg && @dlg.visible?
        end

        # -----------------------------------------------------------

        def show(entity = nil)
          @dlg ||= build_dialog
          @dlg.show

          ent = entity || selected_entity
          if ent
            notify_selection(ent)
          else
            # Garder l'UI ouverte mais afficher une charge vide
            send_to_js("HC.onSelection(null)")
            send_to_js("HC.onPayload(null, null)")
          end
        end

        def notify_selection(entity)
          return unless @dlg && @dlg.visible?
          pid = safe_pid(entity)
          send_to_js("HC.onSelection(#{pid || 'null'})")
          send_payload_for(entity)
        end

        # -------------------------
        # Internals
        # -------------------------

        def build_dialog
          dlg = ::UI::HtmlDialog.new(
            dialog_title: TITLE,
            preferences_key: PREF_KEY,
            scrollable: true,
            resizable: true,
            width: 460,
            height: 760,
            style: ::UI::HtmlDialog::STYLE_DIALOG
          )

          dlg.set_html(read_panel_html)

          dlg.add_action_callback("hc_get_selection") do |_ctx|
            ent = selected_entity
            pid = safe_pid(ent)
            send_to_js("HC.onSelection(#{pid || 'null'})")
          end

          dlg.add_action_callback("hc_get_payload") do |_ctx, pid|
            ent = find_by_pid(pid)
            send_payload_for(ent)
          end

          dlg.add_action_callback("hc_convert_selection") do |_ctx|
            ent = selected_entity
            if ent
              convert_entity(ent)
              notify_selection(ent)
            end
          end

          dlg.add_action_callback("hc_patch") do |_ctx, pid, patch_json|
            ent = find_by_pid(pid)
            patch = safe_parse_json(patch_json)

            if ent && patch.is_a?(Hash)
              patch_entity(ent, patch)
              send_payload_for(ent)
            else
              send_to_js("HC.onPayload(#{pid || 'null'}, null)")
            end
          end

          dlg.add_action_callback("hc_commit") do |_ctx, pid|
            ent = find_by_pid(pid)
            if ent
              commit_entity(ent)
              send_payload_for(ent)
            end
          end

          dlg
        end

        def send_payload_for(entity)
          pid = safe_pid(entity)
          payload = entity ? payload_for(entity) : nil

          json = payload ? JSON.generate(payload) : "null"
          send_to_js("HC.onPayload(#{pid || 'null'}, #{json})")
        rescue => e
          log_exception(e, "send_payload_for")
          send_to_js("HC.onPayload(null, null)")
        end

        def payload_for(entity)
          {
            ok: true,
            pid: safe_pid(entity),
            name: entity.respond_to?(:name) ? entity.name.to_s : "",
            is_group: entity.is_a?(Sketchup::Group),
            is_component: entity.is_a?(Sketchup::ComponentInstance),
            smart: smart_entity?(entity),
            data: read_entity_data(entity)
          }
        end

        def selected_entity
          m = Sketchup.active_model
          return nil unless m
          ent = m.selection.first
          return nil unless ent
          return nil unless ent.is_a?(Sketchup::Group) || ent.is_a?(Sketchup::ComponentInstance)
          ent
        end

        def safe_pid(ent)
          return nil unless ent
          ent.persistent_id
        rescue
          nil
        end

        def find_by_pid(pid)
          return nil unless pid
          m = Sketchup.active_model
          return nil unless m
          ent = m.find_entity_by_persistent_id(pid.to_i)
          return nil unless ent.is_a?(Sketchup::Group) || ent.is_a?(Sketchup::ComponentInstance)
          ent
        rescue => e
          log_exception(e, "find_by_pid")
          nil
        end

        def send_to_js(js)
          return unless @dlg
          @dlg.execute_script(js)
        end

        def read_panel_html
          path1 = File.join(__dir__, "panel.html")
          # Fallback sécurisé
          path2 = File.join(__dir__, "panel.html") 
          path = File.exist?(path1) ? path1 : path2

          if File.exist?(path)
            File.read(path)
          else
            minimal_panel_html
          end
        rescue => e
          log_exception(e, "read_panel_html")
          minimal_panel_html
        end

        def minimal_panel_html
          <<~HTML
            <!doctype html>
            <html>
              <head><meta charset="utf-8"><title>HyperComponents</title></head>
              <body>
                <h3>HyperComponents</h3>
                <p>panel.html manquant.</p>
                <script>
                  window.HC = {
                    onSelection: function(pid){ console.log("selection", pid); },
                    onPayload: function(pid, payload){ console.log("payload", pid, payload); }
                  };
                </script>
              </body>
            </html>
          HTML
        end

        def safe_parse_json(str)
          return {} if str.nil? || str.to_s.strip.empty?
          JSON.parse(str)
        rescue
          {}
        end

        # -------------------------
        # Backend adapters
        # -------------------------

        def smart_entity?(entity)
          return false unless entity
          if defined?(HyperComponents::Core::Serializer) && HyperComponents::Core::Serializer.respond_to?(:smart_component?)
            return HyperComponents::Core::Serializer.smart_component?(entity)
          end
          !!entity.attribute_dictionary("smart_component", false)
        rescue
          false
        end

        def read_entity_data(entity)
          return {} unless entity
          if defined?(HyperComponents::Core::Serializer) && HyperComponents::Core::Serializer.respond_to?(:read)
            return HyperComponents::Core::Serializer.read(entity)
          end
          {
            meta: entity.get_attribute("smart_component", "meta"),
            features: entity.get_attribute("smart_component", "features"),
            state: entity.get_attribute("smart_component", "state")
          }
        rescue => e
          log_exception(e, "read_entity_data")
          {}
        end

        def convert_entity(entity)
          if defined?(HyperComponents::Core::Manager) && HyperComponents::Core::Manager.respond_to?(:instance)
            HyperComponents::Core::Manager.instance.convert!(entity)
          end
        rescue => e
          log_exception(e, "convert_entity")
        end

        def patch_entity(entity, patch_hash)
          if defined?(HyperComponents::Core::Manager) && HyperComponents::Core::Manager.respond_to?(:instance)
            mgr = HyperComponents::Core::Manager.instance
            if mgr.respond_to?(:registry) && mgr.registry.respond_to?(:get)
              rt = mgr.registry.get(entity)
              rt.cache.patch!(patch_hash) if rt && rt.respond_to?(:cache)
              rt.mark_dirty!("ui_patch") if rt && rt.respond_to?(:mark_dirty!)
              return
            end
          end
        rescue => e
          log_exception(e, "patch_entity")
        end

        def commit_entity(entity)
          if defined?(HyperComponents::Core::Manager) && HyperComponents::Core::Manager.respond_to?(:instance)
            mgr = HyperComponents::Core::Manager.instance
            if mgr.respond_to?(:registry) && mgr.registry.respond_to?(:get)
              rt = mgr.registry.get(entity)
              rt.mark_dirty!("ui_commit") if rt && rt.respond_to?(:mark_dirty!)
            end
            mgr.apply_dirty!(Sketchup.active_model) if mgr.respond_to?(:apply_dirty!)
          end
        rescue => e
          log_exception(e, "commit_entity")
        end

        def log_exception(e, ctx)
          if defined?(HyperComponents::Diagnostics::Logger) && HyperComponents::Diagnostics::Logger.respond_to?(:exception)
            HyperComponents::Diagnostics::Logger.exception(e, ctx)
          else
            puts "[HyperComponents][ERROR] #{ctx} #{e.class}: #{e.message}"
            bt = e.backtrace && e.backtrace.first(8)
            puts(bt.join("\n")) if bt
          end
        end
      end
    end
  end
end
