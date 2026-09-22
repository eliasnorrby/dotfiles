# Reduce a Claude Code transcript to what a reader needs: what the user said,
# what the assistant said, and which commands/tools it ran (not their output).
def clip($n): if length > $n then .[0:$n] + " …[clipped]" else . end;
select(.type == "user" or .type == "assistant")
| select(.isSidechain != true)
| .timestamp as $ts
| if .type == "user" then
    (if (.message.content | type) == "string" then
       "\n## USER [\($ts[0:16])]\n" + (.message.content | clip(6000))
     else
       ([.message.content[]? | select(.type == "text") | .text] | join("\n")) as $t
       | if ($t | length) > 0 then "\n## USER [\($ts[0:16])]\n" + ($t | clip(6000)) else empty end
     end)
  else
    ([.message.content[]?
      | if .type == "text" then "\n### ASSISTANT [\($ts[0:16])]\n" + .text
        elif .type == "tool_use" then
          "  > " + .name + ": " + ((.input.command // .input.description // .input.file_path // .input.prompt // .input.query // .input.skill // (.input | tostring)) | tostring | gsub("\n"; " ") | clip(300))
        else empty end] | join("\n")) as $out
    | if ($out | length) > 0 then $out else empty end
  end
