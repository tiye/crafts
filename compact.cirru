
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |touch-control/ |respo.calcit/ |triadica-space/ |quaternion/ |memof/
  :entries $ {}
  :files $ {}
    |app.comp.container $ {}
      :defs $ {}
        |*triangle-counter $ quote (defatom *triangle-counter 0)
        |build-connections $ quote
          defn build-connections (dots)
            -> dots
              mapcat $ fn (d1)
                -> dots $ map
                  fn (d2) ([] d1 d2)
              filter $ fn (ab)
                not= (nth ab 0) (nth ab 1)
        |comp-connections-demo $ quote
          defn comp-connections-demo () $ let
              connections $ build-connections
                map dots $ fn (d) (v-scale d 100)
            comp-tube $ {} (; :draw-mode :line-strip) (:circle-step 20) (:radius 1)
              :vertex-shader $ inline-shader "\"lines.vert"
              :fragment-shader $ inline-shader "\"lines.frag"
              :brush $ [] 16 0
              :brush2 $ [] 6 4
              :curve $ w-js-log
                -> connections $ map
                  fn (line)
                    []
                      {} $ :position (nth line 0)
                      {} $ :position
                        v-scale
                          &v+ (nth line 0) (nth line 1)
                          , 0.5
                      {} $ :position (nth line 1)
              :normal0 $ [] 1 2 0
              ; :get-uniforms $ fn ()
                js-object $ :time
                  &* 0.001 $ - (js/Date.now) start-time
        |comp-container $ quote
          defn comp-container (store)
            let
                states $ :states store
              ; comp-mesh-demo
              group ({})
                if (not hide-tabs?)
                  comp-tabs
                    {}
                      :position $ [] -40 0 0
                      :selected $ :tab store
                    , tab-entries
                case-default (:tab store)
                  do
                    js/console.warn "\"Unknown tab:" $ :tab store
                    comp-axis
                  :axis $ comp-axis
                  :wave $ object
                    {} (:draw-mode :line-strip)
                      :vertex-shader $ inline-shader "\"wave.vert"
                      :fragment-shader $ inline-shader "\"wave.frag"
                      :attributes $ {}
                        :idx $ range 100000
                  :tube $ comp-tube-demo
                  :mesh $ comp-mesh-demo
                  :fibers $ comp-fibers-demo
                  :connections $ comp-connections-demo
        |comp-fibers-demo $ quote
          defn comp-fibers-demo () $ let
              segments 20
            comp-tube $ {} (; :draw-mode :line-strip) (:circle-step 20) (:radius 1)
              :vertex-shader $ inline-shader "\"fibers.vert"
              :fragment-shader $ inline-shader "\"fibers.frag"
              :brush $ [] 16 0
              :brush2 $ [] 6 4
              :curve $ -> fibers-grid
                map $ fn (xy)
                  -> (range segments)
                    map $ fn (idx)
                      let
                          x $ nth xy 0
                          y $ nth xy 1
                          ratio $ / idx segments
                          rr $ + 0.1 (* ratio ratio)
                          decay $ - 1
                            /
                              + (pow x 2) (pow y 2)
                              , 500
                        {}
                          :position $ [] (* 40 idx decay)
                            +
                              * 0.4 $ * idx idx
                              * x 20 rr
                            +
                              * 40 $ sin (* 0.1 idx)
                              * y 20 rr
                          :idx ratio
                          :xy xy
              ; :get-uniforms $ fn ()
                js-object $ :time
                  &* 0.001 $ - (js/Date.now) start-time
        |comp-mesh-demo $ quote
          defn comp-mesh-demo () $ let
              r 100
              da $ * &PI 0.01
              pieces 4
              d-theta $ / (* &PI 2) pieces
              segments 16
              lines-grid $ -> (range-bothway pieces)
                mapcat $ fn (i)
                  -> (range-bothway pieces)
                    map $ fn (j) ([] i j)
            comp-tube $ {} (; :draw-mode :line-strip) (:circle-step 7) (:radius 16)
              :vertex-shader $ inline-shader "\"mesh.vert"
              :fragment-shader $ inline-shader "\"mesh.frag"
              :curve $ -> lines-grid
                map $ fn (base)
                  -> (range segments)
                    map $ fn (idx)
                      let
                          a0 0
                          angle $ + a0 (* idx da)
                          ri $ + 16
                            / (* r idx) segments
                        {} $ :position
                          []
                            +
                              * 80 $ nth base 0
                              ; * ri $ sin angle
                            * idx 10
                            +
                              * 80 $ nth base 1
                              ; * ri $ cos angle
              :post-hook $ fn (d)
                map d $ fn (di)
                  let
                      idx $ triangle-idx!
                    assoc di :idx $ floor
                      - (/ idx 3) 3
        |comp-tube-demo $ quote
          defn comp-tube-demo () $ let
              r 420
              da $ * &PI 0.01
              pieces 24
              d-theta $ / (* &PI 2) pieces
              segments 8
            comp-tube $ {} (; :draw-mode :line-strip) (:circle-step 20) (:radius 6)
              :vertex-shader $ inline-shader "\"vortex.vert"
              :fragment-shader $ inline-shader "\"vortex.frag"
              :brush $ [] 16 0
              :brush2 $ [] 6 4
              :curve $ -> (range pieces)
                map $ fn (p-idx)
                  -> (range segments)
                    map $ fn (idx)
                      let
                          a0 $ * p-idx d-theta
                          angle $ + a0 (* idx da)
                          ri $ + 16
                            / (* r idx) segments
                        {}
                          :position $ []
                            * ri $ cos angle
                            * ri $ sin angle
                            , 0
                          :angle angle
                          :radius ri
              ; :get-uniforms $ fn ()
                js-object $ :time
                  &* 0.001 $ - (js/Date.now) start-time
        |dots $ quote
          def dots $ [] ([] 1 1 1) ([] 1 1 -1) ([] 1 -1 1) ([] 1 -1 -1) ([] -1 1 1) ([] -1 1 -1) ([] -1 -1 1) ([] -1 -1 -1) ([] 0 0 1.414) ([] 0 0 -1.414) ([] 0 1.414 0) ([] 0 -1.414 0) ([] 1.414 0 0) ([] -1.414 0 0)
        |fibers-grid $ quote
          def fibers-grid $ let
              size 8
            -> (range-bothway size)
              mapcat $ fn (x)
                -> (range-bothway size)
                  map $ fn (y) ([] x y)
              filter $ fn (xy)
                <=
                  +
                    pow (nth xy 0) 2
                    pow (nth xy 1) 2
                  * 8 8
        |start-time $ quote
          def start-time $ js/Date.now
        |tab-entries $ quote
          def tab-entries $ []
            {} (:key :axis)
              :position $ [] -200 140 0
            {} (:key :wave)
              :position $ [] -200 100 0
            {} (:key :tube)
              :position $ [] -200 60 0
            {} (:key :mesh)
              :position $ [] -200 20 0
            {} (:key :fibers)
              :position $ [] -200 -20 0
            {} (:key :connections)
              :position $ [] -200 -60 0
        |triangle-idx! $ quote
          defn triangle-idx! () $ let
              v @*triangle-counter
            swap! *triangle-counter inc
            , v
      :ns $ quote
        ns app.comp.container $ :require ("\"twgl.js" :as twgl)
          app.config :refer $ inline-shader hide-tabs?
          triadica.config :as t-config
          triadica.alias :refer $ object group
          triadica.math :refer $ &v+
          triadica.core :refer $ %nested-attribute >>
          triadica.comp.tube :refer $ comp-tube comp-brush
          triadica.comp.tabs :refer $ comp-tabs
          triadica.comp.axis :refer $ comp-axis
          quaternion.core :refer $ &v+ v-scale
    |app.config $ {}
      :defs $ {}
        |hide-tabs? $ quote
          def hide-tabs? $ = "\"true" (get-env "\"hide-tabs" "\"false")
        |inline-shader $ quote
          defmacro inline-shader (file) (println "\"inline shader file:" file)
            read-file $ str "\"shaders/" file
      :ns $ quote (ns app.config)
    |app.main $ {}
      :defs $ {}
        |*store $ quote
          defatom *store $ {}
            :states $ {}
            :tab $ turn-keyword (get-env "\"tab" "\"axis")
        |canvas $ quote
          def canvas $ js/document.querySelector "\"canvas"
        |dispatch! $ quote
          defn dispatch! (op data)
            when dev? $ js/console.log "\"Dispatch:" op data
            let
                store @*store
                next $ case-default op
                  do (js/console.warn "\"unknown op" op) nil
                  :states $ update-states store data
                  :tab-focus $ assoc store :tab data
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
          defn render-app! () (reset! *triangle-counter 0)
            load-objects! (comp-container @*store) dispatch!
            paint-canvas!
      :ns $ quote
        ns app.main $ :require ("\"./calcit.build-errors" :default build-errors) ("\"bottom-tip" :default hud!)
          triadica.config :refer $ dev? dpr
          "\"twgl.js" :as twgl
          touch-control.core :refer $ render-control! start-control-loop! replace-control-loop!
          triadica.core :refer $ on-control-event load-objects! paint-canvas! setup-mouse-events! reset-canvas-size! update-states
          triadica.global :refer $ *gl-context
          app.comp.container :refer $ comp-container *triangle-counter
          triadica.comp.tabs :refer $ comp-tabs
