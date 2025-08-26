#!/usr/local/bin/linescript4
# How to run:
# ln -sf $(pwd)/closeloop.ls /usr/local/bin/closeloop
# ln -sf $(pwd) /usr/local/closeloop
# echo "ok" | ./closeloop.ls TEST

# TODO: better errors when it can't find context because start of file or end of file

# TODO: I think there is an error if there is a newline (empty) after [START OF FILE]
# TODO: see file layout should carry a bit more context
# TODO: potential better patching error, show the part of the file we think it's trying to get, potentially sub loop!

# TODO: this error say "a replace without an end====skipping"

# interesting thing we do. not sure if best
# TOOD: interesting that we only show the latest llmResponse, see updateLiveHistory, "NOTE: Interesting1"
#       So the previous thought process is not included.
#       Also previous commands are not included if they are run again. That's prob ok.

# TODO, only keep the latest patch error around?
# Idea, dumb version with only 1 command at a time

# maybe use xml as separators?
# https://platform.openai.com/docs/guides/text?api-mode=responses#few-shot-learning


# what is your next step?
# given this next step, and a list of available commands, what command should I run?


# TODO: when a patch fails,
# go in to sub patch fixing mode.
# a sub agent loop.

# detect missing end patch
# only keep latest failed patch around
# only allow one patch at a time (stop streaming after failed patch?!)
# better error messages on failed patches!
# instruct about should reference old lines or new lines?
#    like if imports change




# Idea, only keep patches around that fail
# throw away old patches and just show full file?
# but maybe the patch history re-inforces patch format?

# idea truncate large files
# and large test output

include "/usr/local/closeloop/closeloop_test.ls"
var globalCounter 0

def checkStreaming
    var payload {
        # model "gpt-4.1-nano"
        model "gpt-4.1"
        # model "o3"
        # model "o4-mini"
        # reasoning {
        #     effort .medium
        #     summary .auto
        # }
              # I'm tired of brittle ssh port forwarding. give me code for a http-based tcp tunnel in Go.
        input %%
            count to 10
        end
        stream true
        # stream false
    }
    %%
        curl --no-buffer "https://api.openai.com/v1/responses" \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer $OPENAI_API_KEY"  \
          -d @-
    end
    toJson payload
    execBashStdinStream
    as cmd
    say cmd
    waitBash cmd
end
# checkStreaming, exit




var homeDir trim execBash %% echo $HOME
update homeDir ++ "/"


var provider "ollama"
# var model "devstral:24b" # too slow on mac m2 Pro, 32gb

# var model "gemma3:4b"
# var model "qwen2.5vl:7b"
# var model "deepseek-r1:8b"
# var model "devstral:24b"
# var model "qwen2.5vl:7b"

var model "gemma3:12b"
# phi4:14b is promosing at insturction following!
# var model "phi4:14b"
# var model "codellama:13b" # slow for me
# var model "codellama:7b"


# var model "qwen2.5-coder:14b"
# var model "dolphin3:8b"
# var model "phi4-reasoning:14b"

var provider "chatgpt"
# var model "gpt-4.1"
var model "gpt-5"
# var model "o3"
# var model "o4-mini"

if getEnvVar "CLOSELOOP_PROVIDER", isnt ""
    let provider getEnvVar "CLOSELOOP_PROVIDER"
end
if getEnvVar "CLOSELOOP_MODEL", isnt ""
    let model getEnvVar "CLOSELOOP_MODEL"
end

say %%
    Provider: %provider
    Model: %model
end

# debug llmCall
# llmCall provider model %%
#     question, would you (as an llm) rather update files using specific line numbers
#     or just by referencing context lines?
# end
# exit

# testParsing
def testParsing
    say "testing"
    var commandHistory []
    string
    end
    parseCommands
    as parsed
    say "Parsed Commands: " parsed
    processCommands parsed commandHistory
    let commandHistory updateLiveHistory commandHistory
    displayHistory commandHistory
    as d
    say "display history"
    say d
    say ""
    say ""

    displayHistoryLite commandHistory
    as d
    say "display history lite"
    say d
    say ""
    say ""

    say "command history:"
    say commandHistory
    exit
end

# extra loop where I ask if this command is needed.


# {
#     # files [
#     #     "internal/graph/helpers.go"
#     # ]
#     fileRanges [
#         "internal/graph/helpers.go:10-20"
#     ]
#   blocks [
#       "internal/graph/helpers.go @@ func (m *mutationResolver) validateUpc @@ case model.Upcoming"
#       # "internal/graph/helpers.go @@ func (m *mutationResolver) validateUpc"
#   ]
#     # fileLayouts [
#     #     "internal/graph/helpers.go"
#     #     "internal/graph/schema.graphqls"
#     # ]
#     # dirs [
#     #     "internal"
#     # ]
# }
# embedLiveContext
# see
# exit

# %%
#     hello
#     MOVE BLOCK: /goo @@ yo ::: @@ bar
#     SEE DIR: /path/to/dir
#     UPDATE BLOCK: /foo @@ yo
#         ok doke
#         arotchoke
#     END
#     SMTHNG: good
#     SMTHNG: good2
# end
# parseCommands
# say
# exit
var osArgs getOsArgs


# if (len osArgs) (>= 3) and osArgs (at 3) (is "DEBUG")
# if len.osArgs >=.3 and osArgs at.3 is.debug
# if len:osArgs >=3 and isArgs @3 is:"debug"
# if osArgs LEN 3 GTE and osArgs 3 AT "Debug" IS

if len osArgs, >= 3, and osArgs at 3, is "DEBUG"
    say "debugging...."
    stdin toString
    as prompt
    # update prompt ++ newline ++  "What was my original instruction from the top of this prompt?"
    # update prompt ++ newline ++  "What is the name of that schema file?"
    update prompt ++ newline ++  "What is the task I asked you to do at the beginning?"
    say prompt
    say "******** " (len prompt, / 4) "tokens (estimate)"
    llmCall provider model prompt
    as llmResponse
    exit
else if len osArgs, >= 3, and osArgs at 3, is "TEST"
    doTests
    exit
else
    say "not debugging"
end

# %%
#     Hello
#     world
#     # and this
#     OK
#         # or this
# end
# removeComments
# say
# exit

startLoop
exit



def startLoop
    deleteFile homeDir ++ .CLOSELOOP_LLM_RESPONSES
    deleteFile homeDir ++ .CLOSELOOP_RAW
    stdin toString
    as prompt
    agentLoop_liveContext_nextStep provider model prompt
end

def removeComments prompt
    prompt split newline
    filter: not it trim, startsWith "#"
    join newline
end


def agentLoop_dumb_model provider model prompt

end


# maybe the live history isn't great for some things
# chatgpt seemed to get stuck trying to run the same failed command
# Input command output higher up, maybe on failure I need to put it  as last thing
# I should maybe preserve it's thought from run to run?
def agentLoop_liveContext_nextStep provider model prompt
    var commandHistory []

    parseCommands prompt
    as parsedCommands
    processCommands parsedCommands commandHistory
    let commandHistory updateLiveHistory commandHistory
    writeFile (homeDir ++ .CLOSELOOP_COMMAND_HISTORY_LITE) displayHistoryLite commandHistory
    removeCommands prompt
    as prompt
    
    if (getEnvVar "CLOSELOOP_NO_LLM") is "true"
        say "exiting early on request"
        exit
    end

    forever
        say "**** agent loopie ****"

        # ******** Directory Tree of . ********
        # (%getDirectoryTree ".")
        # ******** End directory Tree of . ********

        # Here are the commands you have already run for reference, no need to run the same ones over and over unless intentional. (previous output is above)
        # (% displayHistoryLite commandHistory )

        # Bummer I had to add patch instructions at end again. with gpt-4.1
        # maybe I don't need it anymore?
        %%
            (%removeComments getAgentInstructions)
            ****************
            ******* Begin original task *********
            (%removeComments prompt)
            ******* End original task *********
            (%displayHistory commandHistory)

            Now use the above context to accomplish the task.
            Here is the task again, just in case:
            ******* Begin original task *********
            (%removeComments prompt)
            ******* End original task *********
            # ****************
            # Also remember the patch instructions
            # (%getPatchFileInstructions)
        end
        as fullPrompt
        writeFile (homeDir ++ "CLOSELOOP_LATEST_PROMPT") fullPrompt
        say "******** " (len fullPrompt) "chars"
        say "******** " (len fullPrompt, / 4) "tokens (estimate)"


        llmCall provider model fullPrompt
        as llmResponse

        commandHistory push {
            name "llmResponse"
            content llmResponse
        }

        parseCommands llmResponse
        as parsedCommands
        
        # added because sadly gpt-5 doesn't issue the "DONE: Yes" command as much like gpt-4.1 did
        if len parsedCommands, is 0
            say "@ Counting this as a DONE."
            exit
        end

        processCommands parsedCommands commandHistory
        let commandHistory updateLiveHistory commandHistory
        writeFile (homeDir ++ .CLOSELOOP_COMMAND_HISTORY_LITE) displayHistoryLite commandHistory

        # say %% sleeping 5 seconds
        # sleepMs 5000
    end
end




def displayHistoryLite commandHistory
    var ret []
    commandHistory each command
        if command at name, is "llmResponse"
            ret push "llmResponse... " ++ command at content, slice 1 20
            continue
        end
        ret push command at raw
        if command at body, isnt null
            command at body
            pushTo ret
            ret push "END PATCH"
        end
        if command at error
            ret push "    Error: " ++ command at error
        end
        ret push ""
    end
    ret join newline
end

def displayHistory commandHistory
    var ret []
    ret push "******** Latest States of Your Output and Commands Ran ********"
    ret push string
        Note, here is a collection of commands run plus their latest state.
        So if you see a file or directory or snippet or block here it will always be the latest known version of the file/dir/snippet/block.
        You do not need to request the same file again.
        If you see a shell output here it's the output of the last time it ran.
        You may need to run the shell output again, for example if you want to rerun a test after changing a file.
    end
    ret push "********"
    ret push ""
    ret push ""
    commandHistory each command
        if command at name, is "llmResponse"
            ret push "*** llm generated content"
            ret push command at content
            ret push "*** end llm generated content"
            ret push ""
            continue
        end

        ret push "*** The following command was issued"
        ret push command at raw
        if command at body, isnt null
            command at body
            split newline
            join newline
            pushTo ret
            ret push "END PATCH"
        end
        ret push "*** Here is the response"
        if command at output
            command at output
            split newline
            # map: "    " ++ it
            join newline
            pushTo ret
        end
        if command at error
            ret push "    Error: " ++ command at error
        end
        ret push "*** End resposne"
        ret push ""
        ret push ""
        # ret push %% ******* Output for (%command at raw) *********
        #ret push command at output

        # ret push %% ******* End Output for (%command at raw) *********
    end
    ret push "******** End History ********"
    ret join newline
end


def removeCommands prompt
    prompt split newline
    var newPromptLines []
    each line
        var parts line split ":"
        if len parts, is 1
            newPromptLines push line
            continue
        end

        if parts at 1, upper, is parts at 1
            continue
        end

        newPromptLines push line
    end
    newPromptLines join newline
end


def getDirectoryTree theDir
    var output []
    getDirectoryTreeR theDir "" output
    output join newline
end

def getDirectoryTreeR theDir indent output
    readDir theDir
    each f
        if f is "vendor"
            continue
        end
        if f is ".git"
            continue
        end
        if isDir theDir ++ "/" ++ f
            push output indent ++ f ++ "/"
            getDirectoryTreeR (theDir ++ "/" ++ f) (indent ++ "    ") output
        else
            push output indent ++ f
            continue
        end
    end
end


def replaceFileRange command
    var theError null
    var body command at body
    var argLine command at argLine
    var parts argLine split ":"
    var pathToFile parts at 1
    var lineRange parts at 2
    var lineRangeParts lineRange split "-"
    var startI lineRangeParts at 1, toInt
    var endI lineRangeParts at 2, toInt

    var ret []

    if fileExists pathToFile
        var freshLines []
        readFile pathToFile
        split newline
        as theLines
        theLines each i line
            if i >= startI, and i <= endI
                continue
            end
            if i is endI + 1
                body split newline
                each: pushTo freshLines
            end
            freshLines push line
        end
        # at the end
        if startI > i
            body split newline
            each: pushTo freshLines
        end
        writeFile pathToFile freshLines join newline
        ret push %% *** %pathToFile updated successfully ***
    else
        let theError %% ******** file %pathToFile does not exist ********
    end
    [
        ret join newline
        theError
    ]
end

# TODO: simplified version
# https://aider.chat/docs/more/edit-formats.html

# order no matter, cuz gpt-4.1 was giving me non-consecutive order
# def patchFile command
#     var patchBodyLines command at body, split newline
#     var pathToFile command at argLine
#     var fileContents readFile pathToFile
#     var fileLines fileContents split newline
#     if fileContents is ""
#         let fileLines []
#     end
#     var newFileLines []
# end


def parsePatch body
    var changes []
    changes # so it returns at the end
    var currentChange null
    var patchBodyLines body split newline
    patchBodyLines each patchLineI patchLine
        if patchLine startsWith "@@"
            var sectionHeading patchLine slice 4 -1
            if currentChange is null
                let currentChange {
                    sectionLines []
                    findLines []
                    replaceLines []
                }
                changes push currentChange
            else
                if currentChange at findLines, len, isnt 0, or currentChange at replaceLines, len, isnt 0
                    let currentChange {
                        sectionLines []
                        findLines []
                        replaceLines []
                    }
                    changes push currentChange
                end
            end
            if sectionHeading isnt ""
                currentChange at sectionLines, push sectionHeading
            end
        else
            if currentChange is null
                let currentChange {
                    sectionLines []
                    findLines []
                    replaceLines []
                }
                changes push currentChange
            end
            if patchLine startsWith " "
                currentChange at findLines, push patchLine slice 2 -1
                currentChange at replaceLines, push patchLine slice 2 -1
            else if patchLine startsWith "-"
                currentChange at findLines, push patchLine slice 2 -1
            else if patchLine startsWith "+"
                currentChange at replaceLines, push patchLine slice 2 -1
            else if patchLine is ""
                currentChange at findLines, push ""
                currentChange at replaceLines, push ""
            else
                # if no " " prefix
                # patchRelaxed1
                # for now let's relax the strict rule of requiring " " prefix
                var patchRelaxed1 true
                if not patchRelaxed1
                    drop # drop the changes
                    return "error with patch at line " ++ patchLineI ++ %% . Other than section separators ("@@"), each patch line must start with "+", "-", or " ". Got (% toJson patchLine at 1). Maybe you just need to prefix a context line with a " ".
                else
                    say "@@ Missing prefix, letting it slide" (toJson patchLine at 1)
                    currentChange at findLines, push patchLine
                    currentChange at replaceLines, push patchLine
                end
            end
        end
    end
end

def patchFile pathToFile body
    var fileContents readFile pathToFile
    var fileLines fileContents split newline
    if fileContents is ""
        let fileLines []
    end


    var changes parsePatch body

    # funky but let's make a string be error
    if getType changes, is "string"
        var patchError "*** PATCH ERROR. PATCH WAS NOT APPLIED, PLEASE TRY AGAIN: " ++ changes
        say patchError
        return [ "" patchError ]
    end
    
    
    # say "% The changes:" changes

    changes each changeI change

        # chatgpt will sometimes have a find and replace that's the same
        var findLinesString change at findLines, join newline
        var replaceLinesString change at replaceLines, join newline
        if findLinesString is replaceLinesString
            continue
        end

        # empty ones are ok
        if (change at findLines, len, is 0) and (change at replaceLines, len, is 0) and (change at sectionLines, len, is 0)
            continue
        end

        var fileLinesIndex 1
        var sectionLines change at sectionLines, toSource, eval

        # if you have findLines with START or END, just use the findLines
        if (sectionLines, len, is 1) and (sectionLines at 1, is "[START OF FILE]", or sectionLines at 1, is "[END OF FILE]") and (change at findLines, len, > 0)
            var sectionLines []
        end


        label processSectionLine
        var sectionLine sectionLines shift
        # say "@sectionLine" sectionLine
        if sectionLine isnt null
            # if sectionLine is "[REMOVE BLOCK START]"
            #     update changeI + 1
            #     var nextSection changes sub changeI
            #
            # end

            if sectionLine is "[START OF FILE]"
                let fileLines (change at replaceLines) ++ fileLines
                continue
            end
            if sectionLine is "[END OF FILE]"
                let fileLines fileLines ++ (change at replaceLines)
                continue
            end
            label nextLine
            # say "@checking against" (trim fileLines sub fileLinesIndex)
            # allow trimming
            if not (trim fileLines sub fileLinesIndex) startsWith (sectionLine trim)
                # say "@going up..."
                update fileLinesIndex + 1
                if fileLinesIndex > len fileLines
                    var patchError "*** PATCH ERROR. PATCH WAS NOT APPLIED, PLEASE TRY AGAIN: Could not find section: " ++ sectionLine
                    say patchError
                    return [ "" patchError ]
                end
                goUp nextLine
            end
            goUp processSectionLine
        end
        label doneSection

        if len (change at findLines), is 0, and (change at sectionLines) len, > 0
            # add 1 because we start at the section
            var theIndex fileLinesIndex + 1
            var indexes [theIndex]
        else
            var indexes allIndexesOfLines fileLines fileLinesIndex change at findLines
        end
        # say indexes
        # say fileLinesIndex
        # exit

        # the following check for ambiguous find
        # new relaxed rule (#patchRelaxed 2) allow ambiguous finds a long as there is a section header
        
        if len indexes, > 1
            # It's actually ok if any one we remove yields the same result
            2 (len indexes) loopRange i
                var lastIndex indexes sub i - 1
                var theIndex indexes sub i
                # say "comparing:" [
                #     theIndex,
                #     lastIndex,
                #     len (change at findLines)
                # ]
                
                if theIndex - lastIndex, isnt len (change at findLines)
                    var ambiguousPatchFail true
                    var patchRelaxed2 true
                    if patchRelaxed2
                        update ambiguousPatchFail and change at sectionLines, len, is 0
                    end
                    if ambiguousPatchFail
                        var patchError "*** PATCH ERROR. PATCH WAS NOT APPLIED, PLEASE TRY AGAIN: ambiguous find, please add more context or section headings to remove ambiguity. section number " ++ (changeI)
                        say patchError
                        return [ "" patchError ]
                    else
                        say "@ Allowing ambiguous find, using first find"
                        breakLoop
                    end
                end
            end
            # say "*** spared!"
        end

        if len fileLines, > 0
            if len indexes, is 0
                var indexesIfNoSection allIndexesOfLines fileLines 1 change at findLines
                if len indexesIfNoSection, > 0
                    var patchError "*** PATCH ERROR. PATCH WAS NOT APPLIED, PLEASE TRY AGAIN: Could not find context in section number " ++ (changeI) ++ ". Make sure section heading is correct."
                    say patchError
                    return [ "" patchError ]
                else
                    var patchError "*** PATCH ERROR. PATCH WAS NOT APPLIED, PLEASE TRY AGAIN: Could not find context in section number " ++ (changeI)
                    say patchError
                    return [ "" patchError ]
                end
            end
            var foundIndex indexes at 1
        else
            var foundIndex 1
        end
        var replaceLines change at replaceLines
        var findLines change at findLines

        # say "* Old File Lines:"
        # say fileLines
        let fileLines  (fileLines slice 1 foundIndex - 1) ++ replaceLines ++ fileLines slice (foundIndex + findLines len) -1
        # say "* New File Lines:"
        # say fileLines
    end
    say "@DEBUG NOTE: successful patch"
    writeFile pathToFile fileLines join newline
    return [
        %% *** %pathToFile updated successfully ***
        ""
    ]
end

def allIndexesOfLines fileLines fileLinesIndex findLines
    var indexes []
    label top
    if fileLinesIndex > len fileLines
        return indexes
    end
    var index indexOfLines fileLines fileLinesIndex findLines
    if index is 0
        return indexes
    end
    indexes push index

    let fileLinesIndex index + 1
    goUp top
end

def indexOfLines fileLines fileLinesIndex findLines
    var originalIndex fileLinesIndex
    var lastFoundIndex 0
    var findLinesIndex 1
    var parseState .finding

    update fileLinesIndex - 1

    label yo
    update fileLinesIndex + 1
    var fileLine fileLines sub fileLinesIndex
    var findLine findLines sub findLinesIndex
    # say %% @ (%parseState): %fileLine ||| %findLine
    # say %% *** last found: %lastFoundIndex
    if findLinesIndex > len findLines
        return lastFoundIndex
    end
    if fileLinesIndex > len fileLines
        if findLinesIndex <= len findLines
            return 0
        end
        return lastFoundIndex
    end
    # say %% _aqua (%parseState): %fileLine ||| %findLine
    if parseState is .finding
        if fileLine is findLine
            let parseState .found
            var lastFoundIndex fileLinesIndex
            update findLinesIndex + 1
        end
    else if parseState is .found
        if fileLine is findLine
            update findLinesIndex + 1
        else
            let parseState .finding
            let findLinesIndex 1
            let fileLinesIndex lastFoundIndex
        end
    end
    goUp yo
end

def getPatchFileInstructions
    string
        You can patch a file with the "PATCH FILE:" command, followed by the diff, followed by "END PATCH"

        Here is an example:
        PATCH FILE: path/to/file.txt
        @@ var navFileLeft = function() {
             } else {
                 fileIndex = 0
             }
        -    if (fileIndex > 0) {
        +    if (fileIndex >= 0) {
                 // reusing moveHomeEndTimeout
                 moveHomeEndTimeout = setTimeout(function() {
                     fileIndex = fileIndex + 1
        @@ function cleanUpFiles() {
                             filesToClose.push(file)
                         }
                     }
        -        } else if (file.fileMode == "shell") {
        -                filesToClose.push(file)
        -        } else if (file.fileMode == "terminal") {
        +        } else if (file.fileMode == "terminal" || file.fileMode == "shell") {
                     if (file.pinned) {
                         pinnedFiles.push(file)
                     } else {
        @@ function runScript() {
             }
             if (isWholeFile && (fx.fullPath.endsWith(".sh") || fx.fullPath.endsWith(".ls"))) {
                 let filename = fx.fullPath.split("/").slice(-1)
        +        let code = getShellCodeForRunningFile(filename, theScriptLines, "./" + filename)
                 addTerminalTab()
                 fx.terminalLoadPromise.then(function () {
        -            sendTerminal("./" + filename, function() {
        +            sendTerminal(code, function() {
                         saveWrapper() // hits Enter
                     })
                 })
        END PATCH
        Notice how it's very similar to a git diff, but without line numbers, line numbers are also not included in the individual lines
        The section headings after the "@@" are optional. However, if there is ambiguity, you must either use section headings or context lines to remove the ambiguity!
        For example a patch with only the contents of "-}" is bad. There are probably many curlies in the code. Which one do I remove?
        # Use 3 lines of context by default, or more if needed to disambiguate.
        # If a line isn't being modified and only serves as context, prefer to prefix it with " " instead of removing it then adding it again. That keeps the diff small.
        Context lines (lines in a section not being added or removed) Must start with a space (" ").
        The "@@" sections do not need to match the order that the sections appear in the file.
        Within @@ sections, any span of consecutive lines in the patch, starting with "-" or " ", must match the lines in the original file. If you need to skip lines, just use new @@ sections.
        If you are adding a block of code, be sure to put context lines (like the last few lines of the previous function) to indicate where to at the block.
        You can also use the special section headings, "@@ [START OF FILE]" or "@@ [END OF FILE]", to signitfy when you want to add code to the start or end of a file.
        # This next line for Claude
        Code in those sections must still have the appropriate prefix, just like any other section, either "-", "+", or " ".
        If you get an error trying to patch a file, one thing to help is use "SEE FILE BLOCK", "SEE FILE", or "SEE FILE RANGE" to help get the correct context lines.
        
        If you need to add code before a line use this trick
        PATCH FILE: /path/to/file.txt
        @@
        +Adding
        +some
        +lines
        +Before this line
        -Before this line
        END PATCH
        
    end
end


def updateLiveHistory commandHistory
    # loop backwards
    var newCommandHistory []
    newCommandHistory # so it returns

    var commandI len commandHistory, plus 1
    var seenCommands {}
    forever
        update commandI - 1
        if commandI <= 0
            breakLoop
        end
        var command commandHistory at %commandI
        var rawCommand command at raw

        if not rawCommand contains "PATCH FILE"
            if seenCommands at %rawCommand
                # if command at name, isnt "llmResponse"
                #     command to output "*** output regenerated again, see below ***"
                # end

                # NOTE: Interesting1
                # interesting, we are not even writing these seen commands,
                # so that "output" change above is useless 2025-07-09
                # maybe in the future we want to keep all the llmResponses ?

                # we aren't going to write it for now
                # newCommandHistory unshift command
                continue
            end
            seenCommands to %rawCommand true
        end
        var commandName command at name
        var argLine command at argLine

        newCommandHistory unshift command
        switch commandName
        case "SEE FILE"
            var pathToFile argLine
            var ret []
            if fileExists pathToFile
                readFile pathToFile
                split newline
                as theLines
                var digits theLines len, toString, len
                theLines map i x
                    # %% (%padLeft (i toString) digits " ") %x
                    %% %x
                end
                join newline
                ret push it
            else
                command to error %% ******** file %pathToFile does not exist ********
            end
            command to output ret join newline
        case "SEE FILE LAYOUT"
            var pathToFile argLine
            var ret []
            if fileExists pathToFile
                readFile pathToFile
                split newline
                as theLines
                var digits theLines len, toString, len
                theLines filterMap i x
                    if getIndent x, is "", and x trim, isnt ""
                        %% (%padLeft (i toString) digits " ") %x
                        # %% %x
                        continue
                    end
                    false
                end
                join newline
                ret push it
            else
                command to error %% ******** file %pathToFile does not exist ********
            end
            command to output ret join newline
        case "SEE FILE SKELETON"
            var pathToFile argLine
            var ret []
            if fileExists pathToFile
                readFile pathToFile
                split newline
                as theLines
                var digits theLines len, toString, len
                var indents theLines map line
                    if trim line, is ""
                        -1
                    else
                        getIndent line, len
                    end
                end

                var lastWasSkipped false

                theLines each i line
                    var back3 toInt is 0 indents sub i - 3
                    var back2 toInt is 0 indents sub i - 2
                    var back1 toInt is 0 indents sub i - 1
                    var me toInt is 0 indents sub i
                    var forw1 toInt is 0 indents sub i + 1
                    var forw2 toInt is 0 indents sub i + 2
                    var forw3 toInt is 0 indents sub i + 3

                    var total back3 + back2 + back1 + me + forw1 + forw2 + forw3
                    # if line trim, is string: lineI := state.Get("LineI").(int) //:)
                    #     say indents slice (i - 3) (i + 3)
                    #     say theLines slice (i - 3) (i + 3)
                    #     say "wooow" total
                    #     exit
                    # end

                    if total >= 1
                        # ret push (padLeft (i toString) digits " ") ++ " " ++ line
                        ret push line
                        let lastWasSkipped false
                    else
                        if not lastWasSkipped
                            ret push string: [SKIPPING LINES... If you need to see these lines for a correct PATCH, use the "SEE FILE BLOCK" command]
                        end
                        let lastWasSkipped true
                    end
                end
            else
                command to error %% ******** file %pathToFile does not exist ********
            end
            command to output ret join newline
        case "SEE FILE RANGE"
            var ret []
            var parts argLine split ":"
            var pathToFile parts at 1
            var range parts at 2
            var rangeParts range split "-"
            var startI rangeParts at 1
            var endI rangeParts at 2

            if fileExists pathToFile
                readFile pathToFile
                split newline
                as theLines
                var digits theLines len, toString, len
                theLines slice startI endI
                join newline
                ret push it
            else
                command to error %% ******** file %pathToFile does not exist ********
            end
            command to output ret join newline
        case "SEE DIR"
            var ret []
            var dirPath argLine
            if isDir dirPath
                ret push readDir dirPath, join newline
            else
                command to error %% ******** directory %dirPath does not exist ********
            end
            command to output ret join newline
        case "SEE FILE BLOCK"
            var blockPath argLine
            var parts blockPath split " @@ "
            var pathToFile parts at 1
            var blockPathInFile parts slice 2 -1
            if not fileExists pathToFile
                say "no exist!"
                command to error %% ******** file %pathToFile does not exist ********
                breakSwitch
            end
            var blockCode findBlock pathToFile blockPathInFile false
            if blockCode is ""
                command to error %% *** file exists, but block not found, you need to find this information another way. try grepping, or something. ***
            else
                command to output blockCode
            end
        end
    end
end


def findBlock pathToFile blockPathInFile opposite
    readFile pathToFile, split newline
    as fileLines
    var currBlockPathLine shift blockPathInFile
    var parseState .finding
    var indent ""
    fileLines each lineI line
        switch parseState
        case .finding
            if line trim, startsWith currBlockPathLine trim
                var currBlockPathLine shift blockPathInFile
                if currBlockPathLine is null
                    let parseState .found
                    let startI lineI
                    let indent getIndent line
                end
            end
        case .found
            var newIndent getIndent line
            # if line trim, isnt "", and (newIndent is indent, or lineI is len fileLines)
            
            # had to do this because of "and" parsing :/
            var leftCurly "{"
            if (line trim, isnt "") and (line trim, isnt leftCurly) and (newIndent is indent, or lineI is len fileLines)
                # ret push (fileLines slice startI lineI) join newline
                if opposite
                    (fileLines slice 1 startI - 1) ++ (fileLines slice lineI + 1, -1)
                else
                    fileLines slice startI lineI
                end
                as theLines
                var digits theLines len, toString, len
                theLines map i x
                    # %% (%padLeft (i + startI, - 1, toString) digits " ") %x
                    %% %x
                end
                join newline
                return
            end
        end
    end
    return ""
end



def getIndent line
    var trimmed line trim
    var indexStop line indexOf trimmed
    var indent ""
    if indexStop isnt 1
        let indent line slice 1 indexStop - 1
    end
    indent
end

# knowing this information, what info is crucial to accomplishing the task
def pushUnique list item
    if list indexOf item, is 0
        list push item
    end
end

# Only one output of each unique Command at a time

# keep a history of all commands, but only show the most recent output

def processCommands commands commandHistory
    var hasPatchError false
    commands each command
        var commandName command at name
        var argLine command at argLine

        switch commandName
        case "SEE DIR"
            commandHistory push command
        case "SEE FILE"
            commandHistory push command
        case "SEE FILE LAYOUT"
            commandHistory push command
        case "SEE FILE SKELETON"
            commandHistory push command
        case "SEE FILE RANGE"
            commandHistory push command
        case "SEE BLOCK"
            commandHistory push command
        case "SEE FILE BLOCK"
            commandHistory push command
        case "REMOVE FILE BLOCK"
            commandHistory push command
            var blockPath (command at argLine)
            var parts blockPath split " @@ "
            var pathToFile parts at 1
            var blockPathInFile parts slice 2 -1
            if not fileExists pathToFile
                say "no exist!"
                command to error %% ******** file %pathToFile does not exist ********
                breakSwitch
            end
            # the true means the opposite
            var blockCode findBlock pathToFile blockPathInFile true
            if blockCode is ""
                command to error %% *** file exists, but block not found, you need to find this information another way. try grepping, or something. ***
            else
                writeFile pathToFile blockCode
                command to output %% *** %pathToFile updated successfully ***
            end
        case "PATCH FILE"
            commandHistory push command
            patchFile (command at argLine) (command at body)
            as [output err]
            command to output output
            command to error err
            if err isnt ""
                var hasPatchError true
                command updateAt error ++ newline ++ "*** because of PATCH failure stopping next commands until failure is fixed ***"
                
                # Save the failure to a file
                var theFileName (command at argLine) split "/", at -1
                update globalCounter + 1
                var dirName "patch_error_" ++ nowMs unixMillisToDateTimeInZone "2006_01_02_15_04_05.000" "America/Phoenix", replace "." "_", ++ "_" ++ globalCounter # rand 1 1000
                writeFile (homeDir ++ .CLOSELOOP_PATCH_ERRORS ++ "/" ++ dirName ++ "/" ++ theFileName) readFile (command at argLine)
                writeFile (homeDir ++ .CLOSELOOP_PATCH_ERRORS ++ "/" ++ dirName ++ "/PATCH.txt") (command at body)
                writeFile (homeDir ++ .CLOSELOOP_PATCH_ERRORS ++ "/" ++ dirName ++ "/error.txt") err
                
                var patchCode %%
                    #!/usr/local/bin/linescript4
                    
                    "CLOSELOOP_NO_LLM=true closeloop"
                    string
                        PATCH FILE: (% command at argLine )
                    (%
                        command at body
                        split newline
                        map: "    " ++ it; join newline
                    )
                        END PATCH
                    end
                    execBashStdinStream
                    say
                end
                var scriptFile (homeDir ++ .CLOSELOOP_PATCH_ERRORS ++ "/" ++ dirName ++ "/run_patch.ls")
                writeFile scriptFile patchCode
                execBash %% chmod +x %scriptFile
                
                # say "Temporarily exiting early on patch error: " err
                # exit
                
                # stops processing future commands in the response
                breakLoop

                # exiting early for debugging
                # say "Exiting because of error"
                # say err toJson
                # exit
            end
            # TODO: maybe block or range?

            # we see file after patch so that llm doesn't think a failed patch got made, and so that it can see context more easily
            # if err isnt ""
            #     commandHistory push {
            #         raw "SEE FILE: " ++ command at argLine
            #         name "SEE FILE"
            #         argLine command at argLine
            #     }
            # end


        case "DONE"
            if hasPatchError
                say "Skipping DONE because of patch error"
                breakSwitch
            end
            let commandHistory updateLiveHistory commandHistory
            displayHistory commandHistory
            say
            say "exiting on DONE..."
            exit
        case "SHELL"
            commandHistory push command
            say "running shell" argLine
            execBashCombinedStream argLine
            as origOutput
            let buffer []
            let readIt tee origOutput buffer
            forever
                var chunk readIt 8192
                if chunk is ""
                    goDown doneLoop
                end
                sayRaw chunk
            end
            #doneLoop
            waitBash origOutput
            var exitError lastErr
            join buffer ""
            as response
            if exitError isnt ""
                let response exitError ++ newline ++ response
            end
            command to output response
        default
            say "******************unhandled command" command
            # commandHistory push command
            # command to output "UNKOWN COMMAND: " ++ command at raw ++ newline ++ "Did you possibly prefix the command with extra characters?"
        end
    end
    say "@@ finished parsing commands"
end

def tee reader buffer
    func size
        let chunk read reader size
        buffer push chunk
        chunk
    end
end

# try line numbers
# TODO: UNSEE
# and changing context to simplify


def getAgentInstructions
    %%
        You are an llm coding agent, an you are currently in the middle of a task.
        Part of the task is likely already done.
        Your job is to perform the next most reasonable action or actions needed to complete the task, including completing the task if you can.

        You interact with your environment by issuing commands.
        Only issue these commands if they are needed to complete the next step of the task.

        Here are the available commands:
        # SEE FILE LAYOUT: path/to/file # gives a layout of the file (lines with 0 indentation) along with line numbers
        # SEE FILE SKELETON: path/to/file # gives every line that has 0 indentation plus some context lines with line numbers. (helpful for seeing the gist of a file without using too much context)
        SEE FILE SKELETON: path/to/file # gives every line that has 0 indentation plus some context lines. (helpful for seeing the gist of a file without using too much context)
        SEE FILE: path/to/file # gives the whole file
        SEE FILE RANGE: path/to/file:lineNumberStart-lineNumberEnd # give a range of lines
        SEE FILE BLOCK: path/to/file @@ ActualSubstringOfLine  # Give a block of text from the file, starting with "LineContent"
        SEE FILE BLOCK: path/to/file @@ PrevActualSubstringOfLine @@ NextActualSubtringOfLine  # Give a block of text from the file, starting with "NextContent", that occurs after "PrevContent"
        REMOVE FILE BLOCK: path/to/file @@ PartialMatchOfStartingLineOfBlockToRemove  # remove a block from a file
        SEE DIR: path/to/dir

        (%getPatchFileInstructions)

        # SHELL: shell command here # you can run arbitrary shell commands, cwd is not preserved across calls.
        # Clarification added for Claude
        SHELL: shell command here # you can run arbitrary shell commands, cwd is not preserved across calls. So you'll need to repeat necessary cd commands, for example "cd /path/to/dir && git status"
        DONE: Yes # special command meaning you think it's all done

        You can use "grep" to search in a file to get a line number to start with.
        However it can be very handy to use "SEE FILE BLOCK" to find a chunk.
        for example if you area looking for a function block for the DoThing fuction, you can run

        SEE FILE BLOCK: path/to/file @@ func DoThing

        Note the "SHELL:" prefix is only for shell (bash) commands. The other commands "SEE FILE:", "PATCH FILE:" etc go on their own lines, not prefixed with "SHELL:"

        Do not output markdown, just plaintext.
        Each issued command must be at the start of a new line.
        So no extra characters can come before a command.
        Also remeber that a colon (":") must follow the commamd name. So it's "SEE FILE: /path/to/file" not "SEE FILE path/to/file"

        # so it doesn't get mixed up on itself
        # You can generate your plan enough to output a single command.
        # Don't issue more that a single command. I will come back with the response and ask for a new command.
        # Don't plan the while thing out. Just one step at a time, one command at a time.
        # But please do say why you are issuing the command.
        You can issue more than one command at a time, for example seeing multiple blocks of files if you think that will help.
        Or patching a file, then running tests.
        Please also say your thought process of why you are issuing the command(s)

        Also, remember, only issue these commands if what's given in your context doesn't already include the sufficient information.
        For example don't ask to see file contents if they are already provided in the request.
        If you have enough information to issue a "PATCH FILE" command, please do so.

        Note if you see any test failures, but have since issued file updates, then try running the tests again.

        Ok here goes. Here is the the original task... and note, it may be partially done, use the context provided take the next step or steps.
    end
end


def parseCommands r
    var commands []
    commands # So we don't forget to return it
    r split newline
    as lines
    var i 0
    forever
        update i + 1
        if i > len lines
            breakLoop
            # goDown doneLoop
        end
        var line lines at %i, trim
        line split ": "
        as parts
        if len parts, is 1
            continue
            # goDown myContinue
        end
        parts at 1
        as commandName
        if commandName trim, startsWith "#"
            continue
        end
        if upper commandName, is commandName
            var commandObj {
                raw line
                name commandName
                argLine parts slice 2 -1, join ": "
            }
            # TODO: could this cause problems???
            commandObj updateAt argLine split "#", at 1, trim

            if commandName is "PATCH FILE"
                var startI i
                forever
                    update i + 1
                    if i > len lines
                        breakLoop
                        # goDown doneSubLoop
                    end
                    if lines at %i, trim, is "END PATCH"
                        lines slice startI + 1, i - 1
                        join newline
                        commandObj to body it
                        breakLoop
                        # goDown doneSubLoop
                    end
                end
                #doneSubLoop
            end
            if commandName is "PATCH FILE"
                if commandObj at body, isnt null
                    commands push commandObj
                else
                    say "a replace without an end====skipping"
                end
            else
                commands push commandObj
            end
        end
        #myContinue
    end
    #doneLoop
end

def makeReadSplitter reader delimeter
    var readChunkSize 1024
    if readChunkSize < len delimeter
        say "error chunk size < delimeter"
        exit
    end
    {
        reader reader
        delimeter delimeter
        readChunkSize readChunkSize
        messages []
        leftOver ""
    }
end

# TODO: add timeout
def readMessage readSplitter
    useVars readSplitter
    forever
        if len messages, > 0
            return shift messages
        end
        var chunk read reader readChunkSize
        if chunk len, is 0
            if len leftOver, > 0
                leftOver
                let leftOver ""
                return
            end
            return ""
        end
        var chunk leftOver ++ chunk
        var parts chunk split delimeter
        var leftOver parts pop
        parts each: messages push it
    end
end


def llmCall provider model prompt
    switch provider
    case "ollama"
        ollamaCall model prompt
    case "chatgpt"
        chatGptCall model prompt
    case "anthropic"
        anthropicCall model prompt
    case "lmstudio"
        lmStudioCall model prompt
    default
        say "invalid provider" provider
        exit
    end
end

def ollamaCall model prompt
    var payload {
        model model
        prompt prompt
        stream true
        options {
            num_ctx 128000
            temperature 2.0
        }
        # system removeComments getAgentInstructions
    }
    %%
        curl -X POST --no-buffer "http://localhost:11434/api/generate" \
          -H "Content-Type: application/json" \
          -d @-
    end
    toJson payload
    # dup, say "json payload" it
    execBashStdinStream
    as cmd

    makeReadSplitter cmd newline
    as rs
    var ret ""
    forever
        # say "reading"
        readMessage rs
        as theMessage
        if theMessage is ""
            goDown doneRead
        end
        # say "message is" theMessage
        # {"model":"gemma3:4b","created_at":"2025-05-28T17:47:32.625071Z","response":"Hello","done":false}
        theMessage fromJson
        as parsed
        sayRaw parsed at response
        update ret ++ parsed at response # ret += parsed.response
    end #doneRead
    waitBash cmd
    if lastErr isnt ""
        say "error running ollama: " lastErr
    end
    say ""
    ret
end


def chatGptCall model prompt
    var payload {
        # model "gpt-4.1-nano"
        model model
        input prompt
        stream true
    }
    if model startsWith "o", or (model startsWith "gpt-5")
        payload to reasoning {
            # effort .high
            # effort .low
            effort .minimal
            summary .auto
        }
    end
    %%
        curl --no-buffer "https://api.openai.com/v1/responses" \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer $OPENAI_API_KEY"  \
          -d @-
    end
    as latestCurl
    toJson payload, as latestPayload
    writeFile (homeDir ++ .CLOSELOOP_LATEST_PAYLOAD) latestPayload
    writeFile (homeDir ++ .CLOSELOOP_LATEST_CURL.sh) "cat CLOSELOOP_LATEST_PAYLOAD | " ++ latestCurl
    execBash %% chmod +x ~/CLOSELOOP_LATEST_CURL.sh

    execBashStdinStream latestCurl latestPayload
    as cmd

    makeReadSplitter cmd newline ++ newline
    as rs
    var ret ""
    var count 0
    forever
        update count + 1
        # say "reading"
        readMessage rs
        as theMessage
        if theMessage is ""
            goDown doneRead
        end
        # say "message is" theMessage
        parseChatGptEvent theMessage
        as parsed
        parsed at data, at type, as eventType

        # say theMessage
        appendLine (homeDir ++ .CLOSELOOP_RAW) theMessage

        if eventType is .response.output_item.added
            sayRaw newline
        else if eventType is .response.reasoning_summary_part.added
            say newline
            say "Reasoning..."
        else if eventType is .response.reasoning_summary_text.done
            var oldRet ret
            let ret parsed at data, at text
            if oldRet isnt ""
                let ret oldRet ++ newline ++ newline ++ ret
            end
            say newline
            say "Done reasoning"
        else if eventType is .response.content_part.added
            sayRaw newline
        else if eventType is .response.output_text.delta
            sayRaw parsed at data, at delta
        else if eventType is .response.reasoning_summary_text.delta
            sayRaw parsed at data, at delta
        else if eventType is .response.output_text.done
            # say "the event type is" eventType
            # say parsed
            var oldRet ret
            let ret parsed at data, at text
            if oldRet isnt ""
                let ret oldRet ++ newline ++ newline ++ ret
            end
        else if eventType is .error
            say "ChatGPT Error:"
            say parsed
        else if eventType is .response.failed
            # {
            #     "type": "response.failed",
            #     "sequence_number": 3,
            #     "response": {
            #         "id": "resp_684c9442238881998ad592800a85491d0f62f2b19f3612ee",
            #         "object": "response",
            #         "created_at": 1749849154,
            #         "status": "failed",
            #         "background": false,
            #         "error": {
            #             "code": "rate_limit_exceeded",
            #             "message": "Rate limit reached for gpt-4.1 in organization _____ on tokens per min (TPM): Limit 30000, Used 16849, Requested 15752. Please try again in 5.202s. Visit https://platform.openai.com/account/rate-limits to learn more."
            #         },
            #         "incomplete_details": null,
            #         "instructions": null,
            #         "max_output_tokens": null,
            #         "model": "gpt-4.1-2025-04-14",
            #         "output": [],
            #         "parallel_tool_calls": true,
            #         "previous_response_id": null,
            #         "reasoning": {
            #             "effort": null,
            #             "summary": null
            #         },
            #         "service_tier": "auto",
            #         "store": true,
            #         "temperature": 1,
            #         "text": {
            #             "format": {
            #                 "type": "text"
            #             }
            #         },
            #         "tool_choice": "auto",
            #         "tools": [],
            #         "top_p": 1,
            #         "truncation": "disabled",
            #         "usage": null,
            #         "user": null,
            #         "metadata": {}
            #     }
            # }
            say "ChatGPT Error:"
            say parsed
            var theError parsed at data, at response, at error
            if theError at code, is .rate_limit_exceeded
                if theError at message, contains "Request too large"
                    say "****"
                    say theError at message
                    sat "Exiting"
                    exit
                end
                var secondsToWait toFloat theError at message, findBetween "Please try again in " "s"
                say "SHOULD SLEEP FOR" secondsToWait "Seconds"
                var toWaitMs secondsToWait * 1000, toInt
                say "sleeping" toWaitMs
                sleepMs toWaitMs

            end
        end
        # say "the parsed message is" it
        # sleepMs 1000

        # you could also look at the other 2 but it seems diplicated
        # event: response.output_text.done
        # data: {"type":"response.output_text.done","sequence_number":29,"item_id":"msg_684a42e5f518819db9705f20188519a20e779c52971e08ba","output_index":0,"content_index":0,"text":"Sure! Here we go:\n\n1  \n2  \n3  \n4  \n5  \n6  \n7  \n8  \n9  \n10"}
        #
        # event: response.content_part.done
        # data: {"type":"response.content_part.done","sequence_number":30,"item_id":"msg_684a42e5f518819db9705f20188519a20e779c52971e08ba","output_index":0,"content_index":0,"part":{"type":"output_text","annotations":[],"text":"Sure! Here we go:\n\n1  \n2  \n3  \n4  \n5  \n6  \n7  \n8  \n9  \n10"}}
        #
        # event: response.output_item.done
        # data: {"type":"response.output_item.done","sequence_number":31,"output_index":0,"item":{"id":"msg_684a42e5f518819db9705f20188519a20e779c52971e08ba","type":"message","status":"completed","content":[{"type":"output_text","annotations":[],"text":"Sure! Here we go:\n\n1  \n2  \n3  \n4  \n5  \n6  \n7  \n8  \n9  \n10"}],"role":"assistant"}}

        # if count % 10, is 0
        #     say ""
        # end


    end #doneRead
    waitBash cmd
    if lastErr isnt ""
        say "error running chatgpt: " lastErr
        sleepMs 5000
    end
    say ""
    ret
end

def lmStudioCall model prompt
    var payload {
        model model
        max_tokens 100000,
        # temperature 0.7
        prompt prompt
        stream true
    }
    %%
        curl -X POST --no-buffer "http://localhost:1234/api/v0/completions" \
          -H "Content-Type: application/json" \
          -d @-
    end
    toJson payload
    # dup, say "json payload" it
    execBashStdinStream
    as cmd

    makeReadSplitter cmd newline ++ newline
    as rs
    var ret ""
    forever
        readMessage rs
        as theMessage
        if theMessage is ""
            breakLoop
        end
        # say newline "#coral message is" theMessage newline
        
        # data: {"id":"cmpl-56v22e6fwvayrx1alkqnoe","object":"text_completion","created":1755676189,"model":"openai/gpt-oss-20b","choices":[{"index":0,"text":" said","logprobs":null,"finish_reason":null}]}
        # data: {"id":"cmpl-56v22e6fwvayrx1alkqnoe","object":"text_completion","created":1755676189,"model":"openai/gpt-oss-20b","choices":[{"index":0,"text":",","logprobs":null,"finish_reason":null}]}
        # data: {"id":"cmpl-56v22e6fwvayrx1alkqnoe","object":"text_completion","created":1755676189,"model":"openai/gpt-oss-20b","choices":[{"index":0,"text":" each","logprobs":null,"finish_reason":null}]}
        # data: {"id":"cmpl-56v22e6fwvayrx1alkqnoe","object":"text_completion","created":1755676189,"model":"openai/gpt-oss-20b","choices":[{"index":0,"text":" approach","logprobs":null,"finish_reason":null}]}
        # data: {"id":"cmpl-56v22e6fwvayrx1alkqnoe","object":"text_completion","created":1755676189,"model":"openai/gpt-oss-20b","choices":[{"index":0,"text":" has","logprobs":null,"finish_reason":null}]}
        if theMessage is "data: [DONE]"
            breakLoop
        end
        var parsedMessage theMessage slice 6 -1, fromJson
        # say parsedMessage
        parsedMessage at choices, at 1, at text
        replace "<|message|>" "<|message|>" ++ newline
        as theText
        sayRaw theText
        update ret ++ theText
    end #doneRead
    waitBash cmd
    if lastErr isnt ""
        say "error running lmstudio: " lastErr
    end
    say ""
    
    # update ret replace "<|message|>" "<|message|>" ++ newline
    ret
end

def anthropicCall model prompt
    var payload {
        model model
        # max_tokens 64000,
        max_tokens 32000,
        messages [
            {
                role "user"
                content prompt
            }
        ]
        stream true
    }

    # payload to thinking {
    #     budget_tokens 2048
    #     type "enabled"
    #
    # }

    %%
        curl --no-buffer https://api.anthropic.com/v1/messages \
             --header "x-api-key: $ANTHROPIC_API_KEY" \
             --header "anthropic-version: 2023-06-01" \
             --header "content-type: application/json" \
             -d @-
    end
    as latestCurl
    toJsonF payload, as latestPayload
    writeFile (homeDir ++ .CLOSELOOP_LATEST_PAYLOAD) latestPayload
    writeFile (homeDir ++ .CLOSELOOP_LATEST_CURL.sh) ". drew.env; cat CLOSELOOP_LATEST_PAYLOAD | " ++ latestCurl
    execBash %% chmod +x ~/CLOSELOOP_LATEST_CURL.sh

    execBashStdinStream latestCurl latestPayload
    as cmd

    makeReadSplitter cmd newline ++ newline
    as rs
    var ret ""
    var count 0
    forever
        update count + 1
        # say "reading"
        readMessage rs
        as theMessage
        if theMessage is ""
            goDown doneRead
        end
        # say "message is" theMessage
        parseAnthropicEvent theMessage
        as parsed


        # event: message_start
        # data: {"type":"message_start","message":{"id":"msg_01Bsesw6RkHfxfLbK3ZM8ufM","type":"message","role":"assistant","model":"claude-sonnet-4-20250514","content":[],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":15,"cache_creation_input_tokens":0,"cache_read_input_tokens":0,"output_tokens":3,"service_tier":"standard"}}}
        #
        # event: content_block_start
        # data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}          }
        #
        # event: ping
        # data: {"type": "ping"}
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello! Here"}              }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"'s counting to 50:\n\n1,"} }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" 2, 3, 4, 5, 6, "}    }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"7, 8, 9, 10, 11, 12"}     }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":", 13, 14, "}      }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"15, 16, 17,"}               }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" 18, 19, 20, 21, 22, "} }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"23, 24, 25, 26, 27, 28"}              }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":", 29, 30, 31, 32, 33,"}     }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" 34, 35, 36, 37, 38, "}  }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"39, 40, 41, 42, 43, 44"}          }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":", 45, 46, 47, 48, 49,"}             }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" 50\n\nThere you go! Is there anything else you'd like me to"}  }
        #
        # event: content_block_delta
        # data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" help you with?"}          }
        #
        # event: content_block_stop
        # data: {"type":"content_block_stop","index":0        }
        #
        # event: message_delta
        # data: {"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":179}       }
        #
        # event: message_stop
        # data: {"type":"message_stop"       }

        parsed at data, at type, as eventType
        # say theMessage
        appendLine (homeDir ++ .CLOSELOOP_RAW) theMessage

        if eventType is "content_block_start"
            sayRaw newline
            update ret ++ newline
            
            var text parsed at data, at content_block, at text
            update ret ++ text
            sayRaw text
        else if eventType is "content_block_delta"
            var text parsed at data, at delta, at text
            update ret ++ text
            sayRaw text
        else if eventType is "content_block_stop"
            sayRaw newline
            update ret ++ newline
        else if eventType is "message_stop"
            sayRaw newline
            update ret ++ newline
        else if eventType is .error
            say "Andhropic Error:"
            say parsed
            exit
        end
    end #doneRead
    waitBash cmd
    if lastErr isnt ""
        say "error running anthropic api: " lastErr
        sleepMs 5000
    end
    say ""
    ret
end


def parseChatGptEvent body
    var ret {}
    body split newline
    each
        split ": "
        as parts
        parts at 1, as key
        parts slice 2 -1, join ": ", as value
        ret to %key value
    end
    ret to data ret at data, fromJson
    ret
end
def parseAnthropicEvent body
    var ret {}
    body split newline
    each
        split ": "
        as parts
        parts at 1, as key
        parts slice 2 -1, join ": ", as value
        ret to %key value
    end
    if ret at data, is null
        say "not json?"
        say ret at data
        say body
        exit
    end
    ret to data ret at data, fromJson
    ret
end




exit
