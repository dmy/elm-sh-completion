##
#
# bash/zsh-bashcompinit elm completion script
#
# Copyright (C) 2019-2020 Rémi Lefèvre
# 
# https://github.com/dmy/elm-sh-completion
#
# To install, two options:
#   
#   Option 1: Source the file from your ~/.bashrc or ~/.bash_profile
#     For example:
#       $ mkdir -p ~/.bash
#       $ cd ~/.bash
#       $ git clone https://github.com/dmy/elm-sh-completion.git
#
#     Then on Linux:
#       $ echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
#
#     Or on MacOS X:
#       $ echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bash_profile
#
#   Option 2: Add the file to bash_completion.d
#     If /etc/bash_completion.d exists on your system:
#       $ sudo curl -o /etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
#
#     Or on MacOS X with Homebrew:
#       $ brew install bash-completion
#       $ sudo curl -o /usr/local/etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
#
##

##
#
# Elm home and packages directory
#
##
elm_version="$(elm --version 2>/dev/null)"
if [ $? -ne 0 ]; then
    echo "elm-sh-completion error: cannot run 'elm --version'"
    echo "Please check that elm command is available from PATH."
    return 1
fi
elm_home="${ELM_HOME:-$HOME/.elm}/${elm_version}"
if [ "${elm_version}" = "0.19.0" ]; then
    packages_dir="${elm_home}/package"
    registry="${packages_dir}/versions.dat"
else
    packages_dir="${elm_home}/packages"
    registry="${packages_dir}/registry.dat"
fi
 
##
#
# elm
#
##
_elm ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"
    case "${COMP_WORDS[1]}" in
        --help)
            ;;
        repl)
            flags "$@" '--help --interpreter --no-colors'
            ;;
        init)
            ;;
        reactor)
            flags "$@" '--help --port'
            ;;
        make)
            flags "$@" '--help --debug --optimize --report=json' '--output --docs'
            ;;
        install)
            if [ "$previous_arg" = "install" ]; then
                packages "$word" "--help"
            fi
            ;;
        bump)
            flags "$@" 
            ;;
        diff)
            if [ "$previous_arg" = "diff" ]; then
                packages "$word" "--help"
            elif [ -d "${packages_dir}/${previous_arg}" ]; then
                package_versions "${previous_arg}" "$word"
            elif [ -d "${packages_dir}/${COMP_WORDS[-3]}/${previous_arg}" ]; then
                package_versions "${COMP_WORDS[-3]}" "$word"
            fi
            ;;
        publish)
            flags "$@" '--help'
            ;;
        *)
            flags "$@" '--help repl init reactor make install bump diff publish'
            ;;
    esac
}

##
#
# elm-json
#
##
_elm_json ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"

    local command=""
    find_command help install new tree uninstall upgrade solve completions
    if find_command -h --help -V --version; then
        return 0
    fi

    case "$command" in
        help)
            flags "$@" 'install new tree uninstall upgrade solve completions'
            ;;
        install)
            packages "$word" '--help --test --yes'
            ;;
        new)
            flags "$@" '--help'
            ;;
        tree)
            flags "$@" '' '--help --test'
            ;;
        uninstall)
            packages "$word" '--help --yes'
            ;;
        upgrade)
            flags "$@" '--help --unsafe --yes'
            ;;
        solve)
            case "$previous_arg" in
                -e|--extra)
                    packages "$word"
                    ;;
                *)
                    flags "$@" '--help --minimize --test --extra'
                    ;;
            esac
            ;;
        completions)
            flags "$@" '--help bash zsh fish'
            ;;
        *)
            flags "$@" 'help --help --version --verbose install new tree uninstall upgrade solve completions'
            ;;
    esac
}

##
#
# elm-test
#
##
_elm_test ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"
    case "${previous_arg}" in
        install)
            packages "$word" "--help"
            ;;
        --seed)
            COMPREPLY=($(compgen -W "0" -- "$word"))
            ;;
        --fuzz)
            COMPREPLY=($(compgen -W "100 500" -- "$word"))
            ;;
        --report)
            COMPREPLY=($(compgen -W "json junit console" -- "$word"))
            ;;
        *)
            flags "$@" \
                "--help install --seed --fuzz --report --version --watch" \
                "--compiler"
            ;;
    esac
}

##
#
# Helpers
#
##

# Set command variable to the command found if any
# $@: list of commands
find_command ()
{
    for w in ${COMP_WORDS[@]:1};do
        for cmd in "$@"; do
            if [ "$w" = "$cmd" ]; then
                command="$cmd";
                return 0
            fi
        done
    done
    return 1
}

# $@: all complete arguments + list of completion results
flags ()
{
    local word="$2"
    local lastarg="$3"
    local flags="$4"
    local flags_with_files="$5"

    # Let the shell complete files for these options
    for flag in $flags_with_files; do
        if [ "$lastarg" = "$flag" ]; then
            COMPREPLY=()
            return 0
        fi
    done

    if [ -z "$word" ]; then
        # Return all flags for empty word
        COMPREPLY=($flags $flags_with_files)
    else
        # Return flags matching the word
        COMPREPLY=($(compgen -W "$flags $flags_with_files" -- "$word"))
    fi
}

# packages < 0.19.0
old_packages ()
{
    cat <<-'EOF'
		1602/json-viewer
		1hko/elm-truth-table
		2mol/elm-colormaps
		aardito2/realm
		AaronCZim/to-elm-format-string
		abadi199/dateparser
		abadi199/datetimepicker
		abadi199/datetimepicker-css
		abradley2/elm-form-controls
		abrykajlo/elm-scroll
		adam-r-kowalski/Elm-Css
		adam-r-kowalski/elm-css-legacy
		adeschamps/mdl-context
		adius/vectual
		agrafix/elm-bootforms
		ahstro/elm-konami-code
		ahstro/elm-luhn
		ahstro/elm-ssn-validation
		airtucha/board
		airtucha/pathfinder
		AIRTucha/pathfinder
		akavel/elm-expo
		akbiggs/elm-effects
		akbiggs/elm-game-update
		akoppela/elm-autocomplete
		akoppela/elm-css-extra-properties
		akoppela/elm-css-extra-ptoperties
		alech/elm-calendarweeks
		alepop/elm-google-url-shortener
		alexeisavca/keyframes.elm
		alinz/elm-vector2d
		allo-media/koivu
		alltonp/elm-driveby
		alpacaaa/elm-date-distance
		aluuu/elm-check-io
		alvivi/elm-css-aria
		alvivi/elm-keyword-list
		alvivi/elm-nested-list
		alvivi/elm-widgets
		amaksimov/elm-maybe-pipeline
		amaksimov/elm-multikey-handling
		amazzeo/elm-math-strings
		ambuc/juggling-graph
		amilner42/keyboard-extra
		amitu/elm-formatting
		andre-dietrich/elm-random-pcg-regex
		andrewjackman/toasty-bootstrap
		andybalaam/elm-param-parsing
		antivanov/eunit
		Apanatshka/elm-list-ndet
		Apanatshka/elm-signal-extra
		aphorisme/elm-oprocesso
		apuchenkin/elm-multiway-tree-extra
		apuchenkin/elm-nested-router
		aramiscd/elm-basscss
		aristidesstaffieri/elm-poisson
		arnau/elm-feather
		arowM/elm-chat-scenario
		arowM/elm-check-button
		arowM/elm-default
		arowM/elm-embedded-gist
		arowM/elm-evil-sendmsg
		arowM/elm-istring
		arowM/elm-monoid
		arowM/elm-raw-html
		arowM/elm-show
		arowM/elm-time-machine
		ashelab/elm-cqrs
		astynax/elm-state
		ASVBPREAUBV/elm-flexbox
		athanclark/elm-discrete-transition
		athanclark/elm-duration
		athanclark/elm-every
		athanclark/elm-param-parsing-2
		athanclark/elm-threading
		avh4/elm-diff
		avh4/elm-favicon
		avh4/elm-meshes
		avh4/elm-spec
		avh4/elm-table
		avh4/elm-testable
		avh4/elm-transducers
		avh4/elm-typed-styles
		avh4-experimental/elm-compose-programs
		avh4-experimental/elm-debug-controls-without-datepicker
		avh4-experimental/elm-layout
		azer/elm-ui-styles
		b52/elm-semantic-ui
		bakkemo/elm-collision
		bardt/elm-rosetree
		base-dev/elm-graphql-module
		bcardiff/elm-debounce
		bcardiff/elm-infscroll
		bChiquet/line-charts
		benansell/elm-geometric-transformation
		bendyworks/elm-action-cable
		bernerbrau/elm-css-widgets
		besuikerd/elm-dictset
		billperegoy/elm-form-validations
		billperegoy/elm-sifter
		billstclair/elm-bitwise-infix
		billstclair/elm-digital-ocean
		billstclair/elm-dynamodb
		billstclair/elm-html-template
		billstclair/elm-recovered
		billstclair/elm-recovered-utf8
		billstclair/elm-s3
		billstclair/elm-simple-xml-to-json
		billstclair/elm-system-notification
		billstclair/elm-versioned-json
		billstclair/elm-xml-extra
		bitrage-io/elm-ratequeue
		blacksheepmails/elm-set
		bloom/aviators
		bloom/elm-return
		bloom/remotedata
		blue-dinosaur/lambda
		Bogdanp/elm-ast
		Bogdanp/elm-combine
		Bogdanp/elm-datepicker
		Bogdanp/elm-generate
		Bogdanp/elm-querystring
		Bogdanp/elm-route
		Bogdanp/elm-time
		bohdyone/elm-mdl
		bowst/elm-form
		brainrape/elm-ast
		brainrape/elm-bidict
		brainrape/flex-html
		breezyboa/elm-form-field
		brenden/elm-tree-diagram
		BrianHicks/elm-avl-exploration
		BrianHicks/elm-benchmark
		brightdb/sequence
		bruz/elm-simple-form-infix
		bundsol/json-api-beta
		bundsol/json-api-plus
		burabure/elm-collision
		BuraBure/elm-collision
		bzimmermandev/autogrid
		cacay/elm-void
		cakenggt/elm-net
		CallumJHays/elm-kalman-filter
		CallumJHays/elm-sliders
		CallumJHays/elm-unwrap
		camjc/elm-quiz
		canadaduane/elm-hccb
		canadaduane/typed-svg
		careport/elm-avl
		carwow/elm-core
		carwow/elm-plot
		carwow/elm-theme
		ccapndave/elm-effects-extra
		ccapndave/elm-list-map
		ccapndave/elm-reflect
		ccapndave/elm-tree-path
		ceddlyburge/elm-collections
		Chadtech/ctpaint-keys
		Chadtech/elm-loop
		Chadtech/hfnss
		Chadtech/keyboard-extra-browser
		Chadtech/mail
		Chadtech/order
		Chadtech/random-pcg-pipeline
		Chadtech/tuple-infix
		chendrix/elm-matrix
		chendrix/elm-numpad
		chrisalmeida/graphqelm
		chrisbuttery/elm-greeting
		chrisbuttery/elm-parting
		chrisbuttery/elm-scroll-progress
		chrisbuttery/is-online
		chrisbuttery/reading-time
		circuithub/elm-array-extra
		circuithub/elm-array-focus
		circuithub/elm-bootstrap-html
		circuithub/elm-filepickerio-api-types
		circuithub/elm-function-extra
		circuithub/elm-graphics-shorthand
		circuithub/elm-html-extra
		circuithub/elm-html-shorthand
		circuithub/elm-json-extra
		circuithub/elm-list-extra
		circuithub/elm-list-signal
		circuithub/elm-list-split
		circuithub/elm-maybe-extra
		circuithub/elm-number-format
		circuithub/elm-result-extra
		circuithub/elm-string-split
		cjduncana/three-words
		cjmeeks/elm-calendar
		ckoster22/elm-genetic
		cmditch/mel-bew3
		cobalamin/elm-json-extra
		cobalamin/history-tree
		cobalamin/safe-int
		comsysto/harvest-api
		coreytrampe/elm-vendor
		cotterjd/elm-mdl
		crazymykl/ex-em-elm
		csicar/elm-mathui
		cutsea110/elm-temperature
		dailydrip/elm-emoji
		dalen/elm-charts
		damienklinnert/elm-hue
		damukles/elm-dialog
		danabrams/elm-media
		danabrams/elm-media-source
		Dandandan/Easing
		Dandandan/parser
		danielnarey/elm-bulma-classes
		danielnarey/elm-color-math
		danielnarey/elm-css-basics
		danielnarey/elm-css-frameworks
		danielnarey/elm-css-math
		danielnarey/elm-font-import
		danielnarey/elm-form-capture
		danielnarey/elm-html-tree
		danielnarey/elm-input-validation
		danielnarey/elm-modular-design
		danielnarey/elm-modular-ui
		danielnarey/elm-semantic-content
		danielnarey/elm-semantic-dom
		danielnarey/elm-semantic-effects
		danielnarey/elm-stylesheet
		danielnarey/elm-toolkit
		danielspaniol/elm-tuple-extra
		danmarcab/elm-retroactive
		danpalmer/elm-param-parsing
		danstn/elm-postgrest
		danyx23/elm-dropzone
		dasch/elm-basics-extra
		davcamer/elm-protobuf
		davidpelaez/elm-scenic
		DavidTobin/elm-key
		deadfoxygrandpa/elm-architecture
		deadfoxygrandpa/elm-test
		debois/elm-mdl
		debois/elm-parts
		derekdreery/elm-die-faces
		derrickreimer/elm-keys
		dhruvin2910/elm-css
		dillonkearns/graphqelm
		dillonkearns/graphqelm-demo
		doodledood/elm-split-pane
		dosarf/elm-guarded-input
		DrBearhands/elm-json-editor
		driebit/elm-html-unsafe-headers
		driebit/elm-max-size-dict
		drojas/elm-http-parser
		drojas/elm-task-middleware
		dtraft/elm-classnames
		duncanmalashock/json-rest-api
		dustinfarris/elm-autocomplete
		dustinspecker/capitalize-word
		dustinspecker/dict-key-values
		dustinspecker/is-fibonacci-number
		dustinspecker/last
		dustinspecker/list-join-conjunction
		dustinspecker/us-states
		dwyl/elm-datepicker
		dwyl/elm-input-tables
		dzhu/elm-tags-input
		dzuk-mutant/internettime
		EddyLane/elm-file
		edkv/elm-components
		edvail/elm-polymer
		eeue56/elm-all-dict
		eeue56/elm-alternative-json
		eeue56/elm-debug-json-view
		eeue56/elm-default-dict
		eeue56/elm-flat-matrix
		eeue56/elm-html-in-elm
		eeue56/elm-html-query
		eeue56/elm-html-test
		eeue56/elm-http-error-view
		eeue56/elm-json-field-value
		eeue56/elm-lazy
		eeue56/elm-lazy-list
		eeue56/elm-pretty-print-json
		eeue56/elm-shrink
		eeue56/elm-simple-data
		eeue56/elm-stringify
		eeue56/elm-xml
		egillet/elm-sortable-table
		elb17/multiselect-menu
		eliaslfox/orderedmap
		eliaslfox/queue
		elm-bodybuilder/elegant
		elm-bodybuilder/elm-function
		elm-bodybuilder/formbuilder
		elm-bodybuilder/formbuilder-autocomplete
		elm-bodybuilder/formbuilder-photo
		elm-canvas/element-relative-mouse-events
		Elm-Canvas/element-relative-mouse-events
		elm-canvas/raster-shapes
		elm-community/elm-check
		elm-community/elm-datepicker
		elm-community/elm-function-extra
		elm-community/elm-history
		elm-community/elm-json-extra
		elm-community/elm-lazy-list
		elm-community/elm-linear-algebra
		elm-community/elm-list-extra
		elm-community/elm-material-icons
		elm-community/elm-random-extra
		elm-community/elm-route
		elm-community/elm-test
		elm-community/elm-time
		elm-community/elm-undo-redo
		elm-community/elm-webgl
		elm-community/html-test-runner
		elm-community/lazy-list
		elm-community/linear-algebra
		elm-community/material-icons
		elm-community/parser-combinators
		elm-community/ratio
		elm-community/shrink
		elm-community/svg-extra
		elm-community/webgl
		elm-json-hal/elm-json-hal
		elm-lang/animation-frame
		elm-lang/core
		elm-lang/dom
		elm-lang/geolocation
		elm-lang/html
		elm-lang/http
		elm-lang/keyboard
		elm-lang/lazy
		elm-lang/mouse
		elm-lang/navigation
		elm-lang/page-visibility
		elm-lang/svg
		elm-lang/trampoline
		elm-lang/virtual-dom
		elm-lang/websocket
		elm-lang/window
		elm-tools/documentation
		elm-tools/parser
		elm-tools/parser-primitives
		emilyhorsman/elm-speechrecognition-interop
		emtenet/elm-component-support
		enetsee/elm-color-interpolate
		enetsee/elm-facet-scenegraph
		enetsee/elm-scale
		enetsee/facet-plot-alpha
		enetsee/facet-render-svg-alpha
		enetsee/facet-scenegraph-alpha
		enetsee/facet-theme-alpha
		enetsee/rangeslider
		enetsee/typed-format
		engagesoftware/elm-dnn-localization
		ericgj/elm-accordion-menu
		ericgj/elm-autoinput
		ericgj/elm-quantiles
		ersocon/creditcard-validation
		erwald/elm-edit-distance
		esanmiguelc/elm-validate
		eskimoblood/elm-color-extra
		eskimoblood/elm-parametric-surface
		eskimoblood/elm-simplex-noise
		eskimoblood/elm-wallpaper
		etaque/elm-dialog
		etaque/elm-hexagons
		etaque/elm-route-parser
		etaque/elm-simple-form
		etaque/elm-simple-form-infix
		etaque/elm-transit-router
		evancz/automaton
		evancz/elm-effects
		evancz/elm-graphics
		evancz/elm-html
		evancz/elm-http
		evancz/elm-markdown
		evancz/elm-sortable-table
		evancz/elm-svg
		evancz/focus
		evancz/start-app
		evancz/task-tutorial
		evancz/url-parser
		evancz/virtual-dom
		exdis/elm-sample-package
		FabienHenon/elm-pull-to-refresh
		FabienHenon/jsonapi-decode
		fabiommendes/elm-bricks
		fabiommendes/elm-dynamic-forms
		fabiommendes/elm-sexpr
		fauu/elm-selectable-text
		fbonetti/elm-phoenix-socket
		fdbeirao/elm-sliding-list
		felipesere/elm-github-colors
		fiatjaf/hashbow-elm
		flarebyte/bubblegum-entity
		flarebyte/bubblegum-graph
		flarebyte/bubblegum-ui-preview
		flarebyte/bubblegum-ui-preview-tag
		flarebyte/bubblegum-ui-tag
		flarebyte/bubblegum-ui-textarea
		flarebyte/ntriples-filter
		FMFI-UK-1-AIN-412/elm-formula
		folkertdev/elm-bounding-box
		folkertdev/elm-hexbin
		folkertdev/elm-treemap
		folkertdev/outmessage
		folkertdev/svg-path-dsl
		freakingawesome/drunk-label
		fredcy/elm-debouncer
		fredcy/elm-defer-command
		fredcy/elm-timer
		frenchdonuts/elm-autocomplete
		Fresheyeball/elm-animate-css
		fresheyeball/elm-cardinal
		Fresheyeball/elm-cardinal
		fresheyeball/elm-check-runner
		Fresheyeball/elm-font-awesome
		Fresheyeball/elm-function-extra
		Fresheyeball/elm-guards
		Fresheyeball/elm-nearly-eq
		Fresheyeball/elm-number-expanded
		Fresheyeball/elm-restrict-number
		Fresheyeball/elm-sprite
		Fresheyeball/elm-tuple-extra
		Fresheyeball/elm-yala
		Fresheyeball/perspective
		Fresheyeball/sprite
		gaborv/debouncer
		garetht/elm-dynamic-style
		geekyme/elm-charts
		geppettodivacin/elm-couchdb
		ggpeti/elm-html-decoder
		ggPeti/elm-html-decoder
		ghivert/elm-cloudinary
		ghivert/elm-colors
		ghivert/elm-data-dumper
		ghivert/elm-mapbox
		gilbertkennen/bigint
		gilesbowkett/html-escape-sequences
		Gizra/elm-compat-017
		Gizra/elm-compat-018
		Gizra/elm-dictlist
		Gizra/elm-essentials
		Gizra/elm-restful
		GlobalWebIndex/segment-elm
		gmauricio/elm-semantic-ui
		gribouille/elm-graphql
		gribouille/elm-prelude
		gribouille/elm-table
		grrinchas/elm-graphql-client
		grrinchas/elm-natural
		Guid75/ziplist
		guillaumeboudon/elm-creditcard
		gummesson/elm-csv
		h0lyalg0rithm/elm-select
		halfzebra/elm-aframe
		halfzebra/elm-sierpinski
		hanshoglund/elm-interval
		hardfire/elm-ad-bs
		hawx/elm-mixpanel
		hendore/elm-adorable-avatars
		hendore/elm-port-message
		hendore/elm-temperature
		heyLu/elm-format-date
		hickscorp/elm-bigint
		hoelzro/elm-drag
		HolyMeekrob/elm-font-awesome-5
		hugobessaa/elm-logoot
		humio/elm-plot
		ianp/elm-datepicker
		icidasset/css-support
		id3as/elm-datastructures
		identicalsnowflake/elm-dynamic-style
		identicalsnowflake/elm-typed-styles
		imbybio/cachedremotedata
		imbybio/outmessage-nested
		imeckler/either
		imeckler/empty
		imeckler/iterator
		imeckler/piece
		imeckler/queue
		imeckler/ratio
		imeckler/stage
		indicatrix/elm-bootstrap
		ingara/elm-asoiaf-api
		InsideSalesOfficial/isdc-elm-ui
		iosphere/elm-i18n
		iosphere/elm-logger
		iosphere/elm-network-graph
		iosphere/elm-toast
		ir4y/elm-cursor
		ivanceras/svgbob
		izdi/junk
		jackfranklin/elm-console-log
		jackfranklin/elm-statey
		jackwillis/elm-dialog
		jahewson/elm-graphql-module
		jamby1100/elm-blog-engine
		jamesmacaulay/elm-json-bidirectional
		janiczek/cmd-extra
		Janiczek/color-hcl
		Janiczek/distinct-colors
		Janiczek/elm-architecture-test
		Janiczek/elm-encoding
		janiczek/elm-markov
		Janiczek/package-info
		jaredramirez/elm-parser
		JasonGFitzpatrick/elm-router
		jasonmahr/html-escaped-unicode
		jasonmahr/html-escape-sequences
		jasonmfry/elm-bootstrap
		JasonMFry/elm-bootstrap
		jastice/boxes-and-bubbles
		jastice/forkitharder-elm
		jastice/forkithardermakeitbetter
		jastice/president
		javcasas/elm-decimal
		javcasas/elm-integer
		jcollard/elm-playground
		jcollard/key-constants
		jeffesp/elm-vega
		jergason/elm-hash
		jessitron/elm-http-with-headers
		jessitron/elm-param-parsing
		jfairbank/elm-stream
		jfmengels/elm-ast
		jims/graphqelm
		jinjor/elm-csv-decode
		jinjor/elm-html-parser
		jinjor/elm-inline-hover
		jinjor/elm-time-travel
		jinjor/elm-transition
		jirichmiel/minimax
		jmackie4/elm-bulma
		jmg-duarte/group-list
		joeandaverde/flex-html
		JOEANDAVERDE/flex-html
		joefiorini/elm-time-machine
		JoelQ/elm-dollar
		JoeyEremondi/array-multidim
		JoeyEremondi/elm-MultiDimArray
		JoeyEremondi/elm-SafeLists
		JoeyEremondi/elm-typenats
		JoeyEremondi/LoadAssets
		JoeyEremondi/safelist
		JoeyEremondi/typenats
		johnathanbostrom/selectlist
		johnathanbostrom/selectlist-extra
		john-kelly/elm-interactive-graphics
		john-kelly/elm-postgrest
		john-kelly/elm-rest
		johnpmayer/elm-linear-algebra
		johnpmayer/elm-opaque
		johnpmayer/elm-webgl
		johnpmayer/state
		johnpmayer/tagtree
		johnpmayer/vec2
		jonathanfishbein1/elm-comment
		joneshf/elm-
		joneshf/elm-comonad
		joneshf/elm-constraint
		joneshf/elm-mom
		joneshf/elm-proof
		joneshf/elm-proxy
		joneshf/elm-tail-recursion
		joneshf/elm-these
		joonazan/elm-ast
		joonazan/elm-gol
		joonazan/elm-type-inference
		JordyMoos/elm-clockpicker
		JordyMoos/elm-pageloader
		JordyMoos/elm-quiz
		joshforisha/elm-entities
		jpagex/elm-geoip
		jpagex/elm-loader
		jreut/elm-grid
		jsanchesleao/elm-assert
		jschonenberg/elm-dropdown
		jtanguy/moulin-rouge
		jterbraak/DateOp
		jtojnar/elm-json-tape
		juanedi/charty
		JulianKniephoff/elm-time-extra
		justgook/elm-image-encode
		justgook/elm-tiled-decode
		justinmimbs/elm-arc-diagram
		justinmimbs/elm-date-extra
		justinmimbs/elm-date-selector
		JustusAdam/elm-path
		jvdvleuten/url-parser-combinator
		jvoigtlaender/elm-drag
		jvoigtlaender/elm-drag-and-drop
		jvoigtlaender/elm-gauss
		jvoigtlaender/elm-memo
		jvoigtlaender/elm-warshall
		jwmerrill/elm-animation-frame
		jwoudenberg/elm-test-experimental
		jwoudenberg/html-typed
		jxxcarlson/convolvemachine
		jxxcarlson/geometry
		jxxcarlson/graphdisplay
		jxxcarlson/minilatex
		jxxcarlson/particle
		jystic/elm-font-awesome
		kallaspriit/elm-basic-auth
		kalutheo/elm-snapshot-tests
		karldray/elm-ref
		kennib/elm-maps
		kennib/elm-swipe
		kfish/glsl-pasta
		kfish/quaternion
		kintail/elm-publish-test
		kintail/input-widget
		klaftertief/elm-heatmap
		knewter/elm-rfc5988-parser
		knledg/touch-events
		koctya/elm-plot
		koyachi/elm-sha
		kress95/random-pcg-extra
		krisajenkins/elm-cdn
		krisajenkins/elm-dialog
		krisajenkins/formatting
		krisajenkins/history
		ktonon/elm-aws-core
		ktonon/elm-child-update
		ktonon/elm-english-dictionary
		ktonon/elm-hmac
		ktonon/elm-memo-pure
		ktonon/elm-serverless
		ktonon/elm-serverless-auth-jwt
		ktonon/elm-serverless-cors
		ktonon/url-parser
		KtorZ/elm-notification
		Kwarrtz/render
		lagunoff/elm-mdl
		larribas/elm-image-slider
		larribas/elm-multi-email-input
		laszlopandy/elm-console
		lattenwald/elm-base64
		layer6ai/elm-filter-box
		layer6ai/elm-query-builder
		leonardanyer/elm-combox
		Leonti/elm-material-datepicker
		Leonti/elm-time-picker
		lgastako/elm-select
		liamcurry/elm-media
		LiberisFinance/elm-charts
		Logiraptor/elm-bench
		lorenzo/elm-string-addons
		lorenzo/elm-tree-diagram
		lovasoa/choices
		lovasoa/elm-component-list
		lovasoa/elm-format-number
		lovasoa/elm-jsonpseudolist
		lovasoa/elm-median
		lovasoa/elm-nested-list
		lucamug/elm-style-framework
		lucamug/elm-styleguide-generator
		lucasssm/simpledate
		ludvigsen/elm-svg-ast
		luftzig/elm-quadtree
		Luftzig/elm-quadtree
		lukewestby/accessible-html-with-css-temp
		lukewestby/elm-http-extra
		lukewestby/elm-i18n
		lukewestby-fake-elm-lang-1/redirect-test-1
		lukewestby/lru-cache
		lukewestby/package-info
		lukewestby/worker
		lzrski/elm-polymer
		m00qek/elm-applicative
		M1chaelTran/elm-graphql
		maksar/elm-function-extra
		maksar/elm-workflow
		maorleger/elm-flash
		maorleger/elm-infinite-zipper
		marcosccm/elm-datepicker
		mariohuizar/elm-charts
		mariohuizar/elm-plot
		MartinKavik/elm-combinatorics
		martinos/elm-sortable-table
		martinsk/elm-datastructures
		martin-volf/elm-jsonrpc
		massung/elm-css
		matheus23/elm-drag-and-drop
		matheus23/please-focus-more
		matth-/elm-keyboard-keys
		MatthewJohnHeath/elm-fingertree
		matthewrankin/elm-mdl
		mattjbray/elm-prismicio
		mattrrichard/elm-disjoint-set
		maximoleinyk/elm-parser-utils
		maxsnew/IO
		maxsnew/lazy
		MazeChaZer/elm-ckeditor
		mbr/elm-mouse-events
		mbylstra/elm-html-helpers
		mc706/elm-clarity-ui
		mdgriffith/elm-animation-pack
		mdgriffith/elm-color-mixing
		mdgriffith/elm-debug-watch
		mdgriffith/elm-html-animation
		mdgriffith/elm-style-animation-0.16
		mdgriffith/elm-style-animation-zero-sixteen
		mgold/Elm-Align-Distribute
		mgold/elm-date-format
		mgold/Elm-Format-String
		mgold/elm-join
		mgold/Elm-Multiset
		mgold/elm-random-pcg
		mgold/elm-random-sample
		mgold/Elm-Random-Sampling
		mgold/elm-socketio
		mgold/elm-turtle-graphics
		MichaelCombs28/elm-dom
		MichaelCombs28/elm-mdl
		MichaelCombs28/elm-parts
		MichaelCombs28/unit-list
		micktwomey/elmo-8
		MikaelMayer/parser
		milesrock/elm-creditcard
		miyamoen/elm-todofuken
		mkovacs/quaternion
		mmetcalfe/elm-random-distributions
		monty5811/remote-list
		mpdairy/elm-component-updater
		mpizenberg/elm-debounce
		mpizenberg/elm-image-annotation
		mpizenberg/elm-image-collection
		mpizenberg/elm-mouse-compat
		mpizenberg/elm-mouse-events
		mpizenberg/elm-touch-events
		mrpinsky/elm-keyed-list
		mrumkovskis/pine
		mrvicadai/elm-palette
		mrvicadai/elm-stats
		mthadley/elm-byte
		mukeshsoni/elm-rope
		mulander/diceware
		mxgrn/elm-phoenix-socket
		myrho/dive
		myrho/elm-statistics
		naddeoa/elm-simple-bootstrap
		naddeoa/quick-cache
		naddeoa/stream
		nathanfox/elm-string-format
		nathanjohnson320/coinmarketcap-elm
		nathanjohnson320/ecurve
		nathanjohnson320/elmark
		Natim/elm-workalendar
		ndr-qef/microkanren.elm
		nedSaf/elm-bootstrap-grid
		neurodynamic/elm-parse-html
		newlandsvalley/elm-abc-parser
		newlandsvalley/elm-comidi
		Nexosis/nexosisclient-elm
		nicklawls/elm-html-animation
		nkotzias/elm-jsonp
		noahzgordon/elm-jsonapi-http
		NoRedInk/datetimepicker
		NoRedInk/elm-api-components
		NoRedInk/elm-asset-path
		NoRedInk/elm-check
		NoRedInk/elm-decode-pipeline
		NoRedInk/elm-doodad
		NoRedInk/elm-feature-interest
		NoRedInk/elm-formatted-text
		NoRedInk/elm-lazy-list
		NoRedInk/elm-phoenix
		noredink/elm-plot
		NoRedInk/elm-plot
		NoRedInk/elm-random-extra
		noredink/elm-rollbar
		NoRedInk/elm-shrink
		NoRedInk/elm-string-extra
		NoRedInk/elm-task-extra
		NoRedInk/elm-view-utils
		NoRedInk/json-elm-schema
		NoRedInk/nri-elm-css
		NoRedInk/rocket-update
		NoRedInk/start-app
		noredink/string-conversions
		NoRedInk/string-conversions
		NoRedInk/style-elements
		NoRedInk/view-extra
		norpan/elm-file-reader
		nphollon/collision
		nphollon/collisions
		nphollon/geo3d
		nphollon/interpolate
		nphollon/mechanics
		nphollon/update-clock
		nvaldes/elm-bootstrap
		ohanhi/elm-web-data
		ohanhi/keyboard-extra
		OldhamMade/elm-charts
		oleiade/elm-maestro
		omarroth/elm-dom
		omarroth/elm-parts
		omnidungeon/layout
		ondras/elm-irc
		opensolid/geometry
		opensolid/linear-algebra
		opensolid/linear-algebra-interop
		opensolid/mesh
		opensolid/svg
		opensolid/webgl-math
		opensolid/webgl-math-interop
		Orasund/elm-pair
		orasund/pixelengine
		orus-io/elm-nats
		orus-io/elm-openid-connect
		overminddl1/program-ex
		owanturist/elm-validation
		PaackEng/elm-alert
		pablohirafuji/elm-char-codepoint
		paramanders/elm-hexagon
		Parquery/elm-heatmap
		passiomatic/elm-figma-api
		patrickjtoy/elm-table
		paulcorke/elm-number-format
		paulcorke/elm-string-split
		pdamoc/elm-css
		pdamoc/elm-ports-driver
		peterszerzo/elm-cms
		peterszerzo/elm-gameroom
		pietro909/elm-sticky-header
		Pilatch/elm-simple-port-program
		pinx/elm-mdl
		piotrdubiel/elm-art-in-pi
		powet/elm-funfolding
		poying/elm-router
		poying/elm-style
		poying/sloth.elm
		prikhi/elm-http-builder
		prikhi/remote-status
		primait/elm-autocomplete
		primait/elm-iban
		pristap/smart-text
		pro100filipp/elm-graphql
		proda-ai/elm-browser
		proda-ai/elm-bytes
		proda-ai/elm-date
		proda-ai/elm-datepicker
		proda-ai/elm-file
		proda-ai/elm-http
		proda-ai/elm-iso8601-date-strings
		proda-ai/elm-list-extra
		proda-ai/elm-parser
		proda-ai/elm-time
		proda-ai/elm-url
		project-fuzzball/node
		project-fuzzball/test
		project-fuzzball/test-runner
		prozacchiwawa/effmodel
		publeaks/elm-rivescript
		pukkamustard/elm-identicon
		punie/elm-matrix
		purohit/style-elements
		pwentz/elm-pretty-printer
		pzingg/elm-navigation-extra
		QiTASC/wip-qit
		r31gN/elm-dropdown
		rainteller/elm-capitalize
		rajasharan/elm-automatic-differentiation
		realyarilabs/yarimoji
		reginaldlouis/elm-mdl-flex
		rehno-lindeque/elm-signal-alt
		reiner-dolp/elm-natural-ordering
		relabsoss/elm-date-extra
		remoteradio/elm-widgets
		RGBboy/websocket-server
		rgrempel/elm-route-hash
		rgrempel/elm-route-url
		rhofour/elm-astar
		rhofour/elm-pairing-heap
		rizafahmi/elm-semantic-ui
		rjbma/elm-modal
		rjdestigter/elm-convert-units
		rkrupinski/elm-range-slider
		rluiten/elm-date-extra
		rluiten/lunrelm
		rnons/elm-svg-loader
		rnons/elm-svg-parser
		rnons/ordered-containers
		RobbieMcKinstry/stripe
		robertjlooby/elm-draggable-form
		robertjlooby/elm-generic-dict
		robinpokorny/elm-brainfuck
		robwhitaker/elm-infinite-stream
		robwhitaker/elm-uuid-stream
		robx/elm-edn
		rodinalex/elm-cron
		rogeriochaves/elm-syntax
		rogeriochaves/elm-ternary
		rogeriochaves/elm-testable
		rogeriochaves/elm-testable-css-helpers
		roine/elm-perimeter
		rolograaf/elm-favicon
		RomanErnst/updated-list
		roSievers/font-awesome
		RoyalHaskoningDHV/elm-ditto-events-decoder
		RoyalIcing/datadown-elm
		RoyalIcing/inflexio
		RoyalIcing/lofi-elm
		RoyalIcing/lofi-schema-elm
		rtfeldman/console-print
		rtfeldman/elm-css-helpers
		rtfeldman/elm-css-util
		rtfeldman/hashed-class
		rtfeldman/hex
		rtfeldman/html-test-runner
		rtfeldman/legacy-elm-test
		rtfeldman/node-test-runner
		rtfeldman/selectlist
		rtfeldman/test-update
		rtfeldman/ziplist
		ryannhg/elm-date-format
		ryannhg/elm-moment
		ryanolsonx/elm-mock-http
		ryanolsonx/elm-time-range
		ryan-senn/elm-record-formatter
		s3k/latte-charts
		s6o/elm-simplify
		SamirTalwar/arborist
		sanichi/elm-md5
		Saulzar/elm-keyboard-keys
		Saulzar/key-constants
		sawaken-experiment/elm-lisp-parser
		sch/elm-aspect-ratio
		scottcorgan/elm-css-normalize
		scottcorgan/elm-css-reset
		scottcorgan/elm-html-template
		scottcorgan/elm-keyboard-combo
		scottcorgan/keyboard-combo
		seanhess/elm-style
		seanpile/elm-orbit-controls
		seanpoulter/elm-versioning-spike
		SelectricSimian/elm-constructive
		seurimas/slime
		sgraf812/elm-access
		sgraf812/elm-graph
		sgraf812/elm-intdict
		sgraf812/elm-stateful
		Shearerbeard/stripe
		shelakel/elm-validate
		shmookey/cmd-extra
		shutej/elm-rpcplus-runtime
		SHyx0rmZ/selectable-list
		SidneyNemzer/elm-remote-data
		simanaitis/elm-mdl
		simonewebdesign/elm-timer
		simonh1000/elm-charts
		SimplyNaOH/elm-searchable-menu
		sindikat/elm-array-experimental
		sindikat/elm-list-experimental
		sindikat/elm-matrix
		sindikat/elm-maybe-experimental
		sixty-north/elm-price-chart
		sixty-north/elm-task-repeater
		Skinney/collections-ng
		Skinney/elm-array-exploration
		Skinney/elm-dict-exploration
		Skinney/elm-dict-extra
		Skinney/fnv
		smurfix/elm-dict-tree-zipper
		soenkehahn/elm-operational
		soenkehahn/elm-operational-mocks
		spect88/romkan-elm
		spisemisu/elm-bytes
		spisemisu/elm-merkletree
		spisemisu/elm-sha
		spisemisu/elm-utf8
		splodingsocks/elm-add-import
		splodingsocks/elm-easy-events
		splodingsocks/elm-html-table
		splodingsocks/elm-tailwind
		splodingsocks/elm-type-extractor
		splodingsocks/hipstore-ui
		splodingsocks/validatable
		sporto/elm-autocomplete
		sporto/elm-dropdown
		sporto/erl
		sporto/hop
		Spottt/elm-dialog
		stasdavydov/elm-cart
		stil4m/elm-aui-css
		stil4m/elm-devcards
		stil4m/rfc2822-datetime
		StoatPower/elm-wkt
		stoeffel/datetimepicker
		stowga/elm-datepicker
		stradeup/inco-picker
		stradeup/input
		supermario/html-test-runner
		surprisetalk/elm-font-awesome
		surprisetalk/elm-icon
		surprisetalk/elm-ionicons
		surprisetalk/elm-material-icons
		surprisetalk/elm-open-iconic
		surprisetalk/elm-pointless
		swiftsnamesake/euclidean-space
		SwiftsNamesake/euclidean-space
		SwiftsNamesake/please-focus
		SylvanSign/elm-pointer-events
		synbioz/elm-time-overlap
		szabba/elm-animations
		szabba/elm-laws
		szabba/elm-timestamp
		tapeinosyne/elm-microkanren
		techanvil/key-constants
		teepark/elmoji
		teocollin1995/complex
		terezka/app
		terezka/colors
		terezka/coordinates
		terezka/elm-cartesian-svg
		terezka/elm-charts-alpha
		terezka/elm-plot
		terezka/elm-plot-rouge
		terezka/elm-view-utils
		terezka/url-parser
		tesk9/elm-html-a11y
		tesk9/elm-html-textup
		tesk9/elm-tabs
		tesk9/focus-style-manager
		thalissonmelo/elmcounter
		thaterikperson/elm-blackjack
		thebookofeveryone/elm-composer
		thebritican/elm-autocomplete
		TheDahv/doctari
		TheSeamau5/elm-check
		TheSeamau5/elm-history
		TheSeamau5/elm-html-decoder
		TheSeamau5/elm-lazy-list
		TheSeamau5/elm-material-icons
		TheSeamau5/elm-quadtree
		TheSeamau5/elm-random-extra
		TheSeamau5/elm-rosetree
		TheSeamau5/elm-router
		TheSeamau5/elm-shrink
		TheSeamau5/elm-spring
		TheSeamau5/elm-task-extra
		TheSeamau5/elm-undo-redo
		TheSeamau5/flex-html
		TheSeamau5/GraphicsEngine
		TheSeamau5/selection-list
		TheSeamau5/typographic-scale
		the-sett/elm-multi-dict
		ThinkAlexandria/keyboard-extra
		thomasloh/elm-phone
		ThomasWeiser/elmfire
		ThomasWeiser/elmfire-extra
		thought2/elm-linear-algebra-extra
		thought2/elm-numbers
		thought2/elm-reset
		thought2/elm-vectors
		thSoft/ElmCache
		thSoft/ExternalStorage
		thSoft/key-constants
		tilmans/elm-style-elements-drag-drop
		TimothyDespair/elm-maybe-applicator
		tiziano88/elm-oauth
		tiziano88/elm-tfl
		tlentz/elm-adjustable-table
		tlentz/elm-fancy-table
		toastal/return-optics
		toastal/trinary
		torgeir/elm-github-events
		treffynnon/elm-tfn
		trifectalabs/elm-geojson
		trifectalabs/elm-polyline
		truqu/elm-mustache
		truqu/elm-oauth2.0
		tryzniak/assoc
		tunguski/elm-ast
		turboMaCk/chae-tree
		turboMaCk/grid-solver
		tuxagon/elm-pokeapi
		typed-wire/elm-typed-wire-utils
		ucode/elm-path
		uehaj/IntRange
		utkarshkukreti/elm-inflect
		valberg/elm-django-channels
		vateira/elm-bem-helpers
		vieiralucas/elm-collections
		vilterp/elm-diagrams
		vilterp/elm-html-extra
		vilterp/elm-pretty-print
		vipentti/elm-dispatch
		vmchale/elm-composition
		volumeint/screen-overlay
		volumeint/sortable-table
		warry/ascii-table
		Warry/ascii-table
		Warry/elmi-decoder
		wende/elchemy-library
		wende/elm-ast
		wende/elmchemy-core
		werner/diyalog
		will-clarke/elm-tiled-map
		williamwhitacre/elm-encoding
		williamwhitacre/elm-lexer
		williamwhitacre/gigan
		williamwhitacre/pylon
		williamwhitacre/scaffold
		willnwhite/bigratio
		wintvelt/elm-print-any
		wittjosiah/elm-alerts
		wittjosiah/elm-css
		wjdhamilton/elm-json-api-helpers
		wuct/elm-charts
		xarvh/elm-dropdown-menu
		xarvh/elm-styled-html
		xarvh/lexical-random-generator
		xerono/pinnablecache
		Xerono/pinnablecache
		xerono/pinnedcache
		Xerpa/elm-graphql
		ydschneider/regex-builder
		ymtszw/elm-amazon-product-advertising
		y-taka-23/elm-github-ribbon
		z5h/time-app
		zaidan/elm-collision
		zaidan/elm-gridbox
		zaptic/elm-decode-pipeline-strict
		Zaptic/elm-glob
		zarvunk/tuple-map
		zeckalpha/char-extra
		zeckalpha/elm-sexp
		Zinggi/elm-hash-icon
		Zinggi/elm-obj-loader
		Zinggi/elm-random-general
		Zinggi/elm-random-pcg-extended
		Zinggi/elm-uuid
		Zinggi/elm-webgl-math
		ZoltanOnody/tablueau-parser
		zwilias/elm-avl-dict-exploration
		zwilias/elm-disco
		zwilias/elm-toml
		zwilias/elm-touch-events
		zwilias/elm-transcoder
		zwilias/elm-tree
		zwilias/json-encode-exploration
	EOF
}

# $1: pattern word
# $2: additional completion results to add to packages
packages ()
{
    local word="$1"
    local additional_matches="$2"
    local packages=""
    case "$word" in
        */*@*)
            # Match packages with version after @
            packages=$(cd "${packages_dir}" && echo */*/* | sed 's/\/\([0-9]\)/@\1/g')
            packages="${packages} ${additional_matches}"
            COMPREPLY=($(compgen -W "$packages" -- "$word"))
            ;;
        *)
            # Get all packages
            packages=$(strings -n 2 ${registry} | grep -Eo '[A-Za-z0-9][A-Za-z0-9-]+' | paste -d "/" - - | sort)
            # Remove old packages
            packages=$(comm -23 <(echo "$packages") <(old_packages))

            packages="${packages} ${additional_matches}"
            COMPREPLY=($(compgen -W "$packages" -- "$word"))
            if [ ${#COMPREPLY[@]} -eq 0 ]; then
                # Match packages from partial matches
                COMPREPLY=($(echo "$packages" | grep -i -- "$word"))
            fi
            ;;
    esac
}

# $1: package
# $2: pattern word
# $3: additional completion results to add to versions
package_versions ()
{
    local package="$1"
    local word="$2"
    local additional_matches="$3"
    local versions=$(cd "${packages_dir}/${package}" && echo *)
    versions="${versions} ${additional_matches}"
    COMPREPLY=($(compgen -W "$versions" -- "$word"))
}

##
#
# Setup
#
##

# zsh compat
if [ -n "$ZSH_VERSION" ]; then
    autoload bashcompinit
    bashcompinit
fi

complete -o bashdefault -o default -F _elm elm
complete -o bashdefault -o default -F _elm_json elm-json
complete -o bashdefault -o default -F _elm_test elm-test

# Cygwin compat
if [ Cygwin = "$(uname -o 2>/dev/null)" ]; then
    complete -o bashdefault -o default -F _elm elm.exe
    complete -o bashdefault -o default -F _elm_json elm-json.exe
fi
