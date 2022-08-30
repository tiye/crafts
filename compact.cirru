
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |touch-control/ |respo.calcit/ |triadica-space/ |quaternion/
  :entries $ {}
  :files $ {}
    |app.comp.container $ {}
      :defs $ {}
        |comp-container $ quote
          defn comp-container (store)
            let
                states $ :states store
              object $ {} (:draw-mode :line-strip)
                :vertex-shader $ inline-shader "\"wave.vert"
                :fragment-shader $ inline-shader "\"wave.frag"
                :attributes $ {}
                  :idx $ range 100000
              let
                  r 200
                  da $ * &PI 0.01
                  pieces 16
                  d-theta $ / (* &PI 2) pieces
                  segments 120
                group ({}) & $ -> (range pieces)
                  map $ fn (p-idx)
                    comp-tube $ {} (:circle-step 20) (:radius 4)
                      :vertex-shader $ inline-shader "\"vortex.vert"
                      :fragment-shader $ inline-shader "\"vortex.frag"
                      :brush $ [] 4 4
                      :curve $ -> (range segments)
                        map $ fn (idx)
                          let
                              a0 $ * p-idx d-theta
                              angle $ + a0 (* idx da)
                              ri $ / (* r idx) segments
                            {}
                              :position $ []
                                * ri $ cos angle
                                * ri $ sin angle
                                , 0
                              :angle angle
                              :radius ri
                      :get-uniforms $ fn ()
                        js-object $ :time
                          &* 0.001 $ - (js/Date.now) start-time
        |start-time $ quote
          def start-time $ js/Date.now
      :ns $ quote
        ns app.comp.container $ :require ("\"twgl.js" :as twgl)
          app.config :refer $ inline-shader
          triadica.alias :refer $ object group
          triadica.math :refer $ &v+
          triadica.core :refer $ %nested-attribute >>
          triadica.comp.tube :refer $ comp-tube comp-brush
    |app.config $ {}
      :defs $ {}
        |inline-shader $ quote
          defmacro inline-shader (file) (println "\"inline shader file:" file)
            read-file $ str "\"shaders/" file
      :ns $ quote (ns app.config)
    |app.main $ {}
      :defs $ {}
        |*store $ quote
          defatom *store $ {}
            :states $ {}
        |canvas $ quote
          def canvas $ js/document.querySelector "\"canvas"
        |dispatch! $ quote
          defn dispatch! (op data)
            when dev? $ js/console.log "\"Dispatch:" op data
            let
                store @*store
                next $ case-default op
                  do (js/console.warn "\"unknown op" op) nil
                  :states $ update-states store ([] op data)
                  :cube-right $ update store :v inc
              if (some? next) (reset! *store next)
        |main! $ quote
          defn main! ()
            if dev? $ load-console-formatter!
            twgl/setDefaults $ js-object (:attribPrefix "\"a_")
            ; inject-hud!
            reset-canvas-size! canvas
            reset! *gl-context $ .!getContext canvas "\"webgl"
              js-object $ :antialias true
            render-app!
            render-control!
            start-control-loop! 10 on-control-event
            add-watch *store :change $ fn (v _p) (render-app!)
            set! js/window.onresize $ fn (event) (reset-canvas-size! canvas) (render-app!)
            setup-mouse-events! canvas
        |reload! $ quote
          defn reload! () $ if (nil? build-errors)
            do (remove-watch *store :change)
              add-watch *store :change $ fn (v _p) (render-app!)
              replace-control-loop! 10 on-control-event
              set! js/window.onresize $ fn (event) (reset-canvas-size! canvas) (render-app!)
              setup-mouse-events! canvas
              render-app!
              hud! "\"ok~" "\"OK"
            hud! "\"error" build-errors
        |render-app! $ quote
          defn render-app! ()
            load-objects! (comp-container @*store) dispatch!
            paint-canvas!
      :ns $ quote
        ns app.main $ :require ("\"./calcit.build-errors" :default build-errors) ("\"bottom-tip" :default hud!)
          triadica.config :refer $ dev? dpr
          "\"twgl.js" :as twgl
          touch-control.core :refer $ render-control! start-control-loop! replace-control-loop!
          triadica.core :refer $ on-control-event load-objects! paint-canvas! setup-mouse-events! reset-canvas-size! update-states
          triadica.global :refer $ *gl-context
          app.comp.container :refer $ comp-container
