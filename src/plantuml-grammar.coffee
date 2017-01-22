{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: "PlantUML"
  scopeName: "source.plantuml"
  fileTypes: [ "puml", "plantuml", "pu", "iuml", "txt" ]

  macros:
    keyword_name: 'keyword.control'
    function_name: 'entity.name.function'
    other_name: 'constant'
    file_name: 'string.other.link'
    punct_name: 'punctuation'
    color: /\#\w+/
    color_name: 'constant.other.color'
    entityName: /[\w\u0080-\uFFFF]+/
    entityQuoted: /"[^"]+"/
    entity: /(?:{entityName}|{entityQuoted})/
    entity_name: 'meta.class'
    integer: /(?:[1-9][0-9]*)/
    number: /(?:{integer}|\d+(?:\.\d+)?)/
    number_name: 'constant.numeric'
    arrowColor: ///
                [ox]?
                (?:<<?|\\\\?|//?)?
                -(?:\[({color})\])?-?
                (?:>>?|\\\\?|//?)?
                (?:[ox](?=[\s\]"]))?
                ///
    arrowState: ///(?:
                  -> # equivalent to -right->
                  |
                  -(?:d|do|down|u|up|r|ri|right|l|le|left)?->
                )///

    arrow_name: '{function_name}'
    stringQuoted: /{entityQuoted}/
    string_name: 'string'
    participant: /(?:actor|boundary|control|entity|database|participant)/
    stateSource: /(?:\[\*\])/
    stateSink: /{stateSource}/

  firstLineMatch: /^\s*@startuml/
  patterns: [
    {
      name: 'meta.source.block'
      begin: /^\s*(@startuml)(?:\s+(.*))\s*$/
      beginCaptures:
        '1': { name: '{other_name}' }
        '2': { name: '{file_name}' }
      contentName: 'source'
      end: /^\s*@enduml/
      endCaptures:
        '0': { name: '{other_name}' }
      patterns: [
        include: '#plantuml'
      ]
    }
  ]
  repository:
    'common':
      patterns: [
        {
          include: '#comments'
        }
        {
          include: "#preprocessor"
        }
        {
          name: 'meta.pragma'
          match: /^\s*(!pragma)\s+(\S+)\s+(.*)$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{other_name}' }
            '3': { name: '{string_name}' }
        }
        {
          name: 'meta.scale'
          match: ///^\s*
            (scale)\s+
            (max\s+)?
            (?:
              ({number})
              (?:(\/)({number}))? # scale 2/3
              (?:\s+(width|height))?
              |
              ({number})(\*)({number}) # scale 200*300
            )
            \s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{keyword_name}' }
            '3': { name: '{number_name}' }
            '4': { name: '{punct_name}' }
            '5': { name: '{number_name}' }
            '6': { name: '{keyword_name}' }
            '7': { name: '{number_name}' }
            '8': { name: '{punct_name}' }
            '9': { name: '{number_name}' }
        }
        {
          name: 'meta.skinparam'
          match: /^\s*(skinparam)\s+(\S+)\s+(.*)$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: 'entity.name.tag' }
            '3': { name: 'constant.other' }
        }
        {
          name: 'meta.title.line'
          match: /^\s*(title)\s+(\S.*)$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
        }
        {
          name: 'meta.title.block'
          begin: /^\s*(title)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
          end: /^\s*(end\s*title)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.header.line'
          match: /^\s*(?:(center|left|right)\s+)?(header|footer)\s+(\S.*)$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{keyword_name}' }
            '3': { name: '{string_name}' }
        }
        {
          name: 'meta.header.block'
          begin: /^\s*(?:(center|left|right)\s+)?(header|footer)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{keyword_name}' }
          end: /^\s*(end\s*\2)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.legend.block'
          begin: /^\s*(legend)(?:\s+(left|right|center))?\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{number_name}' }
          end: /^\s*(end\s*legend)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.newpage'
          match: /^\s*(newpage)(?:\s+(.*)?)\s*$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
        }
        {
          name: 'meta.note.block'
          begin: ///
              ^\s*
              ([hr]?note)\s*
              (?:
                \s+((?:left|right)(?:\s+of)?|over)
                (?:\s+
                  ({entity}(?:\s*,\s*{entity})*)
                )?
                (?:\s+({color}))?
              )?\s*
              $
              ///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{number_name}' }
            '3': { name: '{entity_name}' }
            '4': { name: '{color_name}' }
          end: /^\s*(end\s*\1)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.note.line'
          match: ///^\s*
              ([hr]?note)\s*
              (?:
                \s+((?:left|right)(?:\s+of)?|over)
                (?:\s+
                  ({entity}(?:\s*,\s*{entity})*)
                )?
                (?:\s+({color}))?
              )?\s*
              (:)\s*(\S.*)\s*$
              ///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{other_name}' }
            '3': { name: '{entity_name}' }
            '4': { name: '{color_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: '{string_name}' }
        }
        {
          name: 'meta.note.floating'
          match: ///^
              ([hr]?note)\s+
              ({entityQuoted})\s+
              (as)\s+
              ({entityName})\s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
        }
      ]

    'plantuml':
      patterns: [
        {
          include: '#common'
        }
        {
          include: '#sequence_diagram'
        }
        {
          include: '#usecase_diagram'
        }
        {
          include: '#class_diagram'
        }
        {
          include: '#activity_diagram'
        }
        {
          include: '#component_diagram'
        }
        {
          include: '#state_diagram_start'
        }
        {
          include: "#object_diagram"
        }

        # {
        #   # TODO: escaped character
        #   match: '(")([^"]*)(")'
        #   captures:
        #     '1':
        #       name: 'punctuation.definition.string.begin'
        #     '3':
        #       name: 'punctuation.definition.string.end'
        #   name: '{string_name}.double'
        # }
      ]
    'comments':
      patterns: [
        {
          begin: /(^[ \t]+)?(?=\')/
          beginCaptures:
            '1': { name: 'punctuation.whitespace.comment.leading' }
          end: /(?!\G)/
          patterns: [
            {
              name: 'comment.line.singlequote'
              begin: /'/
              beginCaptures:
                '0': { name: 'punctuation.definition.comment' }
              end: /\n/
            }
          ]
        }
        {
          name: 'comment.block'
          begin: /\/'/
          beginCaptures:
            '0': { name: 'punctuation.definition.comment.begin' }
          end: /'\//
          endCaptures:
            '0': { name: 'punctuation.definition.comment.end' }
        }

      ]
    'sequence_diagram':
      patterns: [
        {
          name: 'meta.sequence.divider'
          match: ///
              ^\s*
              (==+)\s*
              ([^=]+)\s*
              (==+)\s*
              $///
          captures:
            '1': { name: '{punct_name}' }
            '2': { name: '{string_name}' }
            '3': { name: '{punct_name}' }
        }
        {
          name: 'meta.sequence.delay'
          match: ///
              ^\s*
              (\.{3})\s*
              (.*)\s*
              (\.{3})\s*
              $///
          captures:
            '1': { name: '{punct_name}' }
            '2': { name: '{string_name}' }
            '3': { name: '{punct_name}' }
        }
        {
          name: 'meta.autonumber'
          match: ///^\s*
              (autonumber)
              \s+(?:(\d+)|({stringQuoted}))?
              \s+(?:(\d+)|({stringQuoted}))?
              \s+(?:({stringQuoted}))?
              \s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: 'constant.numeric' }
            '3': { name: '{string_name}.double' }
            '4': { name: 'constant.numeric' }
            '5': { name: '{string_name}.double' }
            '6': { name: '{string_name}.double' }
        }
        {
          name: 'meta.sequence.ref.line'
          match: ///^\s*
            (ref\s+over)\s+
            ({entity}(?:\s*,\s*{entity})*)\s*
            (:)\s*
            (.*)\s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{punct_name}' }
            '4': { name: '{string_name}' }
        }
        {
          name: 'meta.sequence.ref.block'
          begin: ///^\s*
            (ref\s+over)\s+
            ({entity}(?:\s*(,)\s*{entity})*)\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{punct_name}' }
          end: /^\s*(end(?:\s*ref)?)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.sequence.alt'
          begin: ///^\s*
              (alt|par)
              (?:\s+(.*))?\s*
              $///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
          end: /^\s*(end)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              match: ///^\s*
                  (else)
                  (?:\s+(.*))?\s*
                  $///
              captures:
                '1': { name: '{keyword_name}' }
                '2': { name: '{string_name}' }
            }
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.box'
          begin: /^\s*(box)\s+(.*)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
          end: /^\s*(end\s*box)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.loop'
          begin: /^\s*(loop)(?:\s+(.*)\s+(times))?\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{number_name}' }
            '3': { name: '{keyword_name}' }
          end: /^\s*(end(?:\s*loop)?)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.groupalt'
          begin: ///^\s*
                (opt|loop|break|critical)
                (?:\s+(.*))?
                \s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
          end: /^\s*(end(?:\s+\1)?)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.group'
          begin: /^\s*(group)\s+(.*)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
          end: /^\s*(end(?:\s+\1)?)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.sequence.declaring'
          match: ///^\s*
              (
                create(?:\s+{participant})?
                |
                {participant}
              )\s+
              (?:({entity})\s+(as)\s+)?
              ({entity})
              (?:\s+(<<)\s*
                (?:\((.),({color})\))?
                (.*)
              \s*(>>))?
              (?:\s+({color}))?
              \s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: 'constant.character' }
            '7': { name: '{color_name}' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: '{punct_name}' }
            '10': { name: '{color_name}' }
        }
        {
          name: 'meta.sequence.activate'
          match: /^\s*(activate)\s+({entity})(?:\s+({color}))?\s*$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{color_name}' }
        }
        {
          name: 'meta.sequence.deactivate'
          match: /^\s*(deactivate|destroy)\s+(.*)\s*$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
        }
        {
          name: 'meta.sequence.arrow.incoming'
          match: ///
                ^\s*
                (\[)
                ({arrowColor})\s*
                ({entity})
                (?:\s+(as)\s+({entity}))?\s*
                (:)\s*
                (.*)$
                ///
          patterns: [
            { include: 'sequence_arrow' }
          ]
          captures:
            '1': { name: '{arrow_name}' }
            '2': { name: '{arrow_name}' }
            '3': { name: '{color_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{entity_name}' }
            '7': { name: '{punct_name}' }
            '8': { name: '{string_name}' }
        }
        {
          name: 'meta.sequence.arrow.outgoing'
          match: ///
                ^\s*
                ({entity})\s*
                ({arrowColor})
                (\])\s*
                (:)\s*
                (.*)$
                ///
          captures:
            '1': { name: '{entity_name}' }
            '2': { name: '{arrow_name}' }
            '3': { name: '{color_name}' }
            '4': { name: '{arrow_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: '{string_name}' }
        }
        {
          name: 'meta.sequence.arrow'
          match: ///
                ^\s*
                ({entity})\s*
                ({arrowColor})\s*
                ({entity})
                (?:\s+(as)\s+({entity}))?\s*
                (:)\s*
                (.*)$
                ///
          captures:
            '1': { name: '{entity_name}' }
            '2': { name: '{arrow_name}' }
            '3': { name: '{color_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{entity_name}' }
            '7': { name: '{punct_name}' }
            '8': { name: '{string_name}' }
        }
        {
          name: 'meta.sequence.verticalspace'
          match: ///^\s*
                (?:
                  (\|{3})
                  |
                  (\|\|(\d+)\|\|)
                )\s*$
                ///
          captures:
            '1': { name: '{punct_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{number_name}' }
        }
        {
          name: 'meta.sequence.footbox'
          match: /^\s*(hide\s+footbox)\s*$/
          captures:
            '1': { name: '{keyword_name}' }
        }
      ]
    # TODO: implement usecase_diagram
    'usecase_diagram':
      patterns: [
      ]
    'class_diagram':
      patterns: [
        {
          name: '{arrow_name}'
          match: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s*
              ("[^"]*")?\s*
              (
                  (?:<\|?|\*|(?=<\s)o)?
                  (?:-+|\.+)
                  (?:\|?>|\*|o(?=\s))?
              )\s*
              ("[^"]*")?\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s*
              (?:(:)\s*(<|>)?\s*([^<>]*)\s*(<|>)?\s*)?\s*
              $///
          captures:
            '1': { name: '{entity_name}' }
            '2': { name: '{string_name}' }
            '3': { name: 'keyword.operator' }
            '4': { name: '{string_name}' }
            '5': { name: '{entity_name}' }
            '6': { name: '{punct_name}' }
            '7': { name: 'keyword.operator' }
            '8': { name: '{string_name}' }
            '9': { name: 'keyword.operator' }
        }
        {
          name: 'meta.class.declaring'
          match: ///^\s*
              (class|abstract(?:\s+class)?|interface|annotation|enum)\s+
              ((?:[\w\u0080-\uFFFF]+|"[^"]+")(?:<[^>]+>)?)
              (?:\s+(as)\s+([\w\u0080-\uFFFF]+|"[^"]+"))?\s*
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+({color}))?
              \s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: 'constant.character' }
            '7': { name: '{color_name}' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: '{punct_name}' }
            '10': { name: '{color_name}' }
        }
        {
          name: 'meta.class.declaring.block'
          begin: ///^\s*
              (class|abstract(?:\s+class)?|interface|annotation|enum)\s+
              ((?:[\w\u0080-\uFFFF]+|"[^"]+")(?:<[^>]+>)?)
              (?:\s+(as)\s+([\w\u0080-\uFFFF]+|"[^"]+"))?\s*
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+({color}))?
              \s*({)\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: 'constant.character' }
            '7': { name: '{color_name}' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: '{punct_name}' }
            '10': { name: '{color_name}' }
            '11': { name: '{punct_name}' }
          end: /^\s*(})\s*$/
          endCaptures:
            '1': { name: 'punctuation.definition.block.end' }
          patterns: [
            {
              include: '#class_block'
            }
          ]
        }
        {
          name: 'meta.class.paramater'
          match: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s+
              (:)\s+
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          captures:
            '1': { name: '{entity_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{other_name}' }
            '4': { name: '{keyword_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{entity_name}' }
            '7': { name: 'variable.paramater' }
            '8': { name: 'keyword.operator' }
            '9': { name: '{entity_name}' }
        }
        {
          name: 'meta.class.method'
          begin: ///^\s*
              ([\w\u0080-\uFFFF]+|"[^"]+")\s+
              (:)\s+
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              (\()\s*///
          end: ///\s*
              (\))\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          beginCaptures:
            '1': { name: '{entity_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: 'keyword.other' }
            '4': { name: '{keyword_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{entity_name}' }
            '7': { name: 'entity.name.function' }
            '8': { name: '{punct_name}' }
          endCaptures:
            '1': { name: '{punct_name}' }
            '2': { name: 'keyword.operator' }
            '3': { name: '{entity_name}' }
          patterns: [
            {
              include: '#class_function_arguments'
            }
          ]
        }
      ]
    # TODO: implement activity_diagram
    'activity_diagram':
      patterns: [
        {
          name: 'meta.activitybeta.flow'
          match: /^\s*(start|stop|end|detach)\s*$/
          captures:
            '1': { name: '{keyword_name}' }
        }
        {
          name: 'meta.activitybeta.step'
          begin: /^\s*({color})?(:)/
          beginCaptures:
            '1': { name: '{color_name}' }
            '2': { name: '{punct_name}' }
          end: ///([;<>\|\]\}/])\s*$///
          endCaptures:
            '1': { name: '{punct_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.activitybeta.arrow'
          begin: /^\s*(->|-\[({color})\]->)/
          beginCaptures:
            '1': { name: '{other_name}' }
            '2': { name: '{color_name}' }
          end: /(;)\s*$/
          endCaptures:
            '1': { name: '{punct_name}' }
          contentName: '{string_name}'
        }
        {
          name: 'meta.activitybeta.swimlane'
          match: /^\s*(?:(\|)({color}))?(\|)([^|]+)(\|)\s*$/
          captures:
            '1': { name: '{punct_name}' }
            '2': { name: '{color_name}' }
            '3': { name: '{punct_name}' }
            '4': { name: '{string_name}' }
            '5': { name: '{punct_name}' }
        }
        {
          name: 'meta.activitybeta.if'
          begin: ///^\s*
                (if)\s*
                (\()([^\)]+)(\))\s*
                (then)\s*
                (?:(\()([^\)]+)(\)))?\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
            '4': { name: '{punct_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{punct_name}' }
            '7': { name: '{string_name}' }
            '8': { name: '{punct_name}' }
          end: /^\s*(endif)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
            {
              name: 'meta.activitybeta.elseif'
              match: ///^\s*
                    (elseif)\s*
                    (\()([^\)]+)(\))\s*
                    (then)\s*
                    (?:(\()([^\)]+)(\)))?\s*$///
              captures:
                '1': { name: '{keyword_name}' }
                '2': { name: '{punct_name}' }
                '3': { name: '{string_name}' }
                '4': { name: '{punct_name}' }
                '5': { name: '{keyword_name}' }
                '6': { name: '{punct_name}' }
                '7': { name: '{string_name}' }
                '8': { name: '{punct_name}' }
            }
            {
              name: 'meta.activitybeta.else'
              match: ///^\s*
                    (else)\s*
                    (?:
                      (\()([^\)]+)(\))
                    )?\s*$///
              captures:
                '1': { name: '{keyword_name}' }
                '2': { name: '{punct_name}' }
                '3': { name: '{string_name}' }
                '4': { name: '{punct_name}' }
            }
          ]
        }
        {
          name: 'meta.activitybeta.while'
          begin: ///^\s*
                (while)\s*
                (\()([^\)]+)(\))
                (?:
                  \s*(is)\s*
                  (\()([^\)]+)(\))
                )?\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
            '4': { name: '{punct_name}' }
            '5': { name: '{keyword_name}' }
            '6': { name: '{punct_name}' }
            '7': { name: '{string_name}' }
            '8': { name: '{punct_name}' }
          end: ///^\s*
                (end\s*while)
                (?:
                  \s*
                  (\()([^\)]+)(\))
                )?
                \s*$///
          endCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
            '4': { name: '{punct_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
          ]
        }
        {
          name: 'meta.activitybeta.repeat'
          begin: /^\s*(repeat)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
          end: /^\s*(repeat\s+while)\s*(\()([^\)]+)(\))\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
            '4': { name: '{punct_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
          ]
        }
        {
          name: 'meta.activitybeta.fork'
          begin: /^\s*(fork)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
          end: /^\s*(end\s*fork)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
            {
              name: 'meta.activitybeta.forkagain'
              match: /^\s*(fork\s+again)\s*$/
              captures:
                '1': { name: '{keyword_name}' }
            }
          ]
        }
        {
          name: 'meta.activitybeta.split'
          begin: /^\s*(split)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
          end: /^\s*(end\s*split)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
            {
              name: 'meta.activitybeta.splitagain'
              match: /^\s*(split\s+again)\s*$/
              captures:
                '1': { name: '{keyword_name}' }
            }
          ]
        }
        {
          name: 'meta.activitybeta.partition'
          begin: /^\s*(partition)\s*(.*)\s*(\{)\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{string_name}' }
            '3': { name: '{punc_name}' }
          end: /^\s*(\})\s*$/
          endCaptures:
            '1': { name: '{punc_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#activity_diagram'
            }
          ]
        }
      ]
    # TODO: implement component_diagram
    'component_diagram':
      patterns: [
      ]
    # TODO: implement state_diagram
    'state_diagram_start':
      patterns: [
        {
          name: 'meta.state.start.arrow'
          begin: ///^\s*
              ({stateSource})\s*
              ({arrowState})\s*
              ({entity})\s*
              (?:(:)\s*(.*))?
              \s*$///
          beginCaptures:
            '1': { name: '{other_name}' }
            '2': { name: '{arrow_name}' }
            '3': { name: '{entity_name}' }
            '4': { name: '{punct_name}' }
            '5': { name: '{string_name}' }
          end: /(?=@enduml)/
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#state_diagram'
            }
          ]
        }
        {
          name: 'meta.state.start.declaring'
          begin: /(?=^\s*state\s+)/
          end: /(?=@enduml)/
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#state_diagram'
            }
          ]
        }
      ]
    'state_diagram':
      patterns: [
        {
          name: 'meta.state.arrow'
          match: ///^\s*
              (?:({stateSource})|({entity}))\s*
              ({arrowState})\s*
              (?:({entity})|({stateSink}))
              (?:\s*(:)\s+(.*))?
              \s*$///
          captures:
            '1': { name: '{other_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{arrow_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{other_name}' }
            '6': { name: '{punct_name}' }
            '7': { name: '{string_name}' }
        }
        {
          name: 'meta.state.comment'
          match: /^\s*({entity})\s*(:)\s*(.*)\s*$/
          captures:
            '1': { name: '{entity_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
        }
        {
          name: 'meta.state.comment'
          match: /^\s*(--|\|\|)\s*$/
          captures:
            '1': { name: '{punct_name}' }
        }
        {
          name: 'meta.state.declaring.block'
          begin: ///^\s*
              (state)\s+
              (?:({entityQuoted})\s+(as)\s+)?
              ({entity})
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+({color}))?
              \s*({)\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: 'constant.character' }
            '7': { name: '{color_name}' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: '{punct_name}' }
            '10': { name: '{color_name}' }
            '11': { name: '{punct_name}' }
          end: /^\s*(})\s*$/
          endCaptures:
            '1': { name: '{punct_name}' }
          patterns: [
            {
              include: '#common'
            }
            {
              include: '#state_diagram'
            }
          ]
        }
        {
          name: 'meta.state.declaring.inline'
          match: ///^\s*
              (state)\s+
              (?:({entityQuoted})\s+(as)\s+)?
              ({entity})
              (?:\s+(<<)\s*
                  (?:\((.),(\#?\w+)\))?\s*
                  ([^<>\(\)]+)?\s*
              (>>))?
              (?:\s+({color}))?
              \s*$///
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: '{punct_name}' }
            '6': { name: 'constant.character' }
            '7': { name: '{color_name}' }
            '8': { name: 'string.other.stereotype' }
            '9': { name: '{punct_name}' }
            '10': { name: '{color_name}' }
        }
      ]
    # TODO: implement object_diagram
    'object_diagram':
      patterns: [
      ]
    # TODO: implement usecase
    'usecase_diagram':
      patterns: [
      ]
    'class_block':
      patterns: [
        {
          name: 'meta.class.separator'
          match: ///^\s*
              (--+|\.\.+|==+|__+)\s*
              (?:
                  ([^-\.=__]+)\s*
                  (--+|\.\.+|==+|__+)\s*
              )?
              $///
          captures:
            '1': { name: 'keyword.operator' }
            '2': { name: '{string_name}' }
            '3': { name: 'keyword.operator' }
        }
        {
          name: 'meta.class.paramater'
          match: ///^\s*
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $///
          captures: {
            '1': { name: 'keyword.other' }
            '2': { name: '{keyword_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: 'variable.paramater' }
            '6': { name: 'keyword.operator' }
            '7': { name: '{entity_name}' }
          }
        }
        {
          name: 'meta.class.method'
          begin: ///
              ^\s*
              (-|\#|~|\+)?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (\{(?:static|classifier|abstract)\})?\s*
              (?:
                  ([^\(\):\s][^\(\):]*)\s+
              )?
              ([^\(\):\s]+)\s*
              (\()\s*
              ///
          beginCaptures: {
            '1': { name: 'keyword.other' }
            '2': { name: '{keyword_name}' }
            '3': { name: '{keyword_name}' }
            '4': { name: '{entity_name}' }
            '5': { name: 'entity.name.function' }
            '6': { name: '{punct_name}' }
          }
          end: ///
              \s*
              (\))\s*
              [^\(\):]*
              (?:
                  (:)\s*
                  (\S.*(?!<\s))?
              )?\s*
              $
              ///
          endCaptures: {
            '1': { name: '{punct_name}' }
            '2': { name: 'keyword.operator' }
            '3': { name: '{entity_name}' }
          }
          patterns: [
            {
              include: '#class_function_arguments'
            }
          ]
        }
      ]
    'class_function_arguments':
      patterns: [
        {
          name: 'meta.function.argument'
          match: ///\s*
              (?:
                  ([^\(\):,\s][^\(\):,]*)\s+
              )?
              ([^\(\):,\s]+)\s*
              (?:
                  (:)\s*
                  ([^\(\):,\s][^\(\):,]*(?!<\s))
              )?\s*,?\s*
              ///
          captures: {
            '1': { name: '{entity_name}' }
            '2': { name: 'variable.paramater' }
            '3': { name: 'keyword.operator' }
            '4': { name: '{entity_name}' }
          }
        }
      ]

    'preprocessor':
      patterns: [
        {
          name: 'meta.preprocessor.include'
          match: /^\s*(!include)\s+(.*)$/
          captures: {
            '1': { name: '{keyword_name}' }
            '2': { name: '{entity_name}' }
          }
        }
        {
          name: 'meta.preprocessor.define'
          begin: /^\s*(!define)\s+({entityName})(?:(\()([^)]*)(\)))?\s*/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{function_name}' }
            '3': { name: '{punct_name}' }
            '4': { name: '{string_name}' }
            '5': { name: '{punct_name}' }
          end: /\s*$/
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.preprocessor.undef'
          match: /^\s*(!undef)\s+({entityName})\s*$/
          captures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{function_name}' }
        }
        {
          name: 'meta.preprocessor.definelong'
          begin: ///^\s*(!definelong)\s+({entityName})(\()([^)]*)(\))\s*$///
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{function_name}' }
            '3': { name: '{punct_name}' }
            '4': { name: '{string_name}' }
            '5': { name: '{punct_name}' }
          end: /^\s*(!end\s*definelong)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.preprocessor.ifdef'
          begin: /^\s*(!ifn?def)\s+({entityName})\s*$/
          beginCaptures:
            '1': { name: '{keyword_name}' }
            '2': { name: '{function_name}' }
          end: /^\s*(!endif)\s*$/
          endCaptures:
            '1': { name: '{keyword_name}' }
          patterns: [
            {
              include: '#plantuml'
            }
          ]
        }
        {
          name: 'meta.preprocessor.macrocall'
          match: /^\s*({entityName})(\()([^)]*)(\))\s*$/
          captures:
            '1': { name: '{function_name}' }
            '2': { name: '{punct_name}' }
            '3': { name: '{string_name}' }
            '4': { name: '{punct_name}' }
        }
      ]


makeGrammar grammar, "CSON"
