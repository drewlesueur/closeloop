# How to run:
# rm -f /usr/local/bin/closeloop
# rm -f /usr/local/closeloop
# ln -sf $(pwd)/closeloop.ls /usr/local/bin/closeloop
# ln -sf $(pwd) /usr/local/closeloop
# echo "ok" | ./closeloop.ls TEST

def doTests
    say "testing"
    def testParsePatch1
        string
            @@
            -Line1
            +Line Numermo Uno
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
        ]
    end
    
    def testParsePatch2
        string
            @@ Section1
            -Line1
            +Line Numermo Uno
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                    "Section1"
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
        ]
    end
    def testParsePatch2_5
        string
            @@ Section1
            -Line1
            @@ Section2
            +Yo
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                    "Section1"
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                ]
            }
            {
                sectionLines [
                    "Section2"
                ]
                findLines [
                ]
                replaceLines [
                    "Yo"
                ]
            }
        ]
    end
    def testParsePatch3
        string
            @@ Section1
            @@ Section1A
            -Line1
            +Line Numermo Uno
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                    "Section1"
                    "Section1A"
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
        ]
    end
    def testParsePatch4
        string
            @@
            -Line1
            +Line Numermo Uno
            @@
            -Line17
            +Line Numermo 17
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
            {
                sectionLines [
                ]
                findLines [
                    "Line17"
                ]
                replaceLines [
                    "Line Numermo 17"
                ]
            }
        ]
    end
    def testParsePatch5
        string
            @@
            -Line1
            +Line Numermo Uno
            @@ A
            @@ B
            -Line17
            +Line Numermo 17
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
            {
                sectionLines [
                    "A"
                    "B"
                ]
                findLines [
                    "Line17"
                ]
                replaceLines [
                    "Line Numermo 17"
                ]
            }
        ]
    end
    def testParsePatch6
        string
            -Line1
            +Line Numermo Uno
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                ]
                replaceLines [
                    "Line Numermo Uno"
                ]
            }
        ]
    end
    def testParsePatch7
        string
            @@
            -Line1
             Line2
            +Line3
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                    "Line2"
                ]
                replaceLines [
                    "Line2"
                    "Line3"
                ]
            }
        ]
    end
    def testParsePatch8
        string
            @@
            -Line1
            -Line2
             Line3
             Line4
            -Line5
            +Line5.5
            +Line5.6
            -Line6
            -Line7
            +Line 7.5
            +Line 7.6
             Line8
            +Line9
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                    "Line2"
                    "Line3"
                    "Line4"
                    "Line5"
                    "Line6"
                    "Line7"
                    "Line8"
                ]
                replaceLines [
                    "Line3"
                    "Line4"
                    "Line5.5"
                    "Line5.6"
                    "Line 7.5"
                    "Line 7.6"
                    "Line8"
                    "Line9"
                ]
            }
        ]
    end
    
    def testParsePatch9
        string
            @@
            -Line1
            +Line Numermo Uno
             }
        end
        parsePatch
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                    "}"
                ]
                replaceLines [
                    "Line Numermo Uno"
                    "}"
                ]
            }
        ]
    end
    
    # patchRelaxed1
    def testParsePatch10
        string
            @@
            -Line1
            +Line Numermo Uno
            }
        end
        parsePatch
        # assertSame it string: error with patch at line 4. Other than section separators ("@@"), each patch line must start with "+", "-", or " ". Got "}". Maybe you just need to prefix a context line with a " ".
        assertSame it [
            {
                sectionLines [
                ]
                findLines [
                    "Line1"
                    "}"
                ]
                replaceLines [
                    "Line Numermo Uno"
                    "}"
                ]
            }
        ]
    end

    def testRemoveComments
        string
            Hello
            # world
            Hi
            # all
        end
        removeComments
        assertEq it string
            Hello
            Hi
        end

    end
    
    def testIndexOfLines
        var lines [1 2 3 4 5]
        var find [3 4]
        assertEq (indexOfLines lines 1 find) 3
    end
    def testIndexOfLines2
        var lines [1 2 3 4 5]
        var find [99]
        assertEq (indexOfLines lines 1 find) 0
    end
    def testIndexOfLines3
        var lines [1 2 3 4 5]
        var find [1 2 3]
        assertEq (indexOfLines lines 1 find) 1
    end
    def testIndexOfLines4
        var lines []
        var find [1 2 3]
        assertEq (indexOfLines lines 1 find) 0
    end
    def testIndexOfLines5
        var lines [1 2 3 4 5]
        var find [4 5]
        assertEq (indexOfLines lines 1 find) 4
    end
    def testIndexOfLines6
        var lines [1 2 3 4 5]
        var find [4 5 6]
        assertEq (indexOfLines lines 1 find) 0
    end
    def testAllIndexesOfLines1
        var lines [1 2 3 4 5]
        var find [2 3]
        assertSame (allIndexesOfLines lines 1 find) [2]
    end
    def testAllIndexesOfLines2
        var lines [2 3 2 3 4 2 3]
        var find [2 3]
        assertSame (allIndexesOfLines lines 1 find) [1 3 6]
    end
    def testAllIndexesOfLines3
        var lines [2 2 2 2]
        var find [2]
        assertSame (allIndexesOfLines lines 1 find) [1 2 3 4]
    end

    def testPatching1_sectionHeader
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi world
            This cool
            func sayHi() {
                println("hi")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ func sayHi
            -    println("hi")
            +    println("yo")
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi world
            This cool
            func sayHi() {
                println("yo")
            }
        end
    end
    
    # saw this in gpt-5. Prompting problem on my end?
    def testPatching1_indentation_on_END_PATCH
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi world
            This cool
            func sayHi() {
                println("hi")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ func sayHi
            -    println("hi")
            +    println("yo")
             END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi world
            This cool
            func sayHi() {
                println("yo")
            }
        end
    end
    
    
    def testPatching1_sectionHeaderTrim
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi world
            This cool
                func sayHi() {
                println("hi")
                }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ func sayHi
            -    println("hi")
            +    println("yo")
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi world
            This cool
                func sayHi() {
                println("yo")
                }
        end
    end
    def testPatching1_sectionHeaderDuplicated
        writeFile .drew.txt %%
            Hi world
            This cool
            func sayHi() {
                println("hi")
                println("how you?")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ func sayHi
            -    println("hi")
            +    println("yo")
            @@ func sayHi
            -    println("how you?")
            +    println("how doing?")
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi world
            This cool
            func sayHi() {
                println("yo")
                println("how doing?")
            }
        end
    end
    
    # should I? I got this with go imports
    # def testPatching1_allowDifferentOrder
    #     deleteFile .delme.txt
    #     writeFile .drew.txt %%
    #         A
    #         B
    #     end
    #     var commandHistory []
    #     string
    #         PATCH FILE: drew.txt
    #         @@
    #         -B
    #         +b
    #         @@
    #         -A
    #         +a
    #         END PATCH
    #     end
    #     parseCommands
    #     processCommands it commandHistory
    #     readFile .drew.txt
    #     assertEq it %%
    #         a
    #         b
    #     end
    # end
    
    def testPatching1_sectionHeader2
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Yo
            func sayHi() {
                #hey
                println("hi")
            }
            func sayBye() {
                #cya
                println("bye")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ func sayHi
            -    println("hi")
            +    println("yo")
            @@ func sayBye
            -    println("bye")
            +    println("cao")
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            func sayHi() {
                #hey
                println("yo")
            }
            func sayBye() {
                #cya
                println("cao")
            }
        end
    end
    def testPatching1_sectionHeader3
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Yo
            func sayHi() {
                #hey
                println("hi")
            }
            # Wow
            func sayBye() {
                #cya
                println("bye")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -    println("hi")
            +    println("yo")
            @@ # Wow
            @@ func sayBye
            -    println("bye")
            +    println("cao")
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            func sayHi() {
                #hey
                println("yo")
            }
            # Wow
            func sayBye() {
                #cya
                println("cao")
            }
        end
    end
    
    def testPatching1
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -They are good
            +They are really good
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            How are things?
            They are really good
            Ok
        end
    end
    
    def testPatching1_at
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            +Hi
            @@
            -Ok
            +Dokie
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
            How are things?
            They are good
            Dokie
        end
    end
    
    def testPatching1_at2
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Wow
            Hello world
            How are things?
            They are good
            Ok
            Cool
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            +Hi
            +Hi2
            @@
            -Ok
            +Dokie
            +Dokie2
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Wow
            Hi
            Hi2
            How are things?
            They are good
            Dokie
            Dokie2
            Cool
        end
    end
    
    def testPatching1_at3
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Wow
            Hello world
            How are things?
            They are good
            Ok
            Cool
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
             Wow
            -Hello world
             How are things?
            +Let's see
            @@
            -Ok
             Cool
            +Really cool
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Wow
            How are things?
            Let's see
            They are good
            Cool
            Really cool
        end
    end
    
    def testPatching2
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -They are good
            -Ok
            +They are really good
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            How are things?
            They are really good
        end
    end

    def testPatching3
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -They are good
            -Ok
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            How are things?
        end
    end

    def testPatching5
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            +Yo world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo world
            How are things?
            They are good
            Ok
        end
    end
    def testPatching6
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            -How are things?
            +Yo world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo world
            They are good
            Ok
        end
    end
    def testPatching7
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok

        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Ok
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            How are things?
            They are good

        end
    end
    def testPatching8
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            How are things?
            They are good
            Ok
        end
    end

    def testPatching9
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
        end
    end

    def testPatching10
        deleteFile .delme.txt
        writeFile .drew.txt %%
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            +hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            hi
        end
    end

    def testPatching11
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            Hello world
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            -How are things?
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            Hello world
            They are good
            Ok
        end
    end
    
    def testPatching12
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hello world
            Hello world
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hello world
            -How are things?
            +Yay
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello world
            Hello world
            Yay
            They are good
            Ok
        end
    end
    
    def testPatching13
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi
            Hello world
            Hello world
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hi
            +Yo
            @@
            -Hello world
            -How are things?
            +Yay
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            Hello world
            Hello world
            Yay
            They are good
            Ok
        end
    end
    
    def testPatching14
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi
            Hello world
            Hello world
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hi
            +Yo
            @@
             Hello world
            -Hello world
            -How are things?
            +Yay
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            Hello world
            Hello world
            Yay
            They are good
            Ok
        end
    end
    def testPatching15
        # any number of @@ does not break
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi
            Hello world
            Hello world
            Hello world
            How are things?
            They are good
            Ok
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -Hi
            +Yo
            @@
            @@
             Hello world
            -Hello world
            -How are things?
            +Yay
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            Hello world
            Hello world
            Yay
            They are good
            Ok
        end
    end
    
    def testPatchingAtStart
        # any number of @@ does not break
        writeFile .drew.txt %%
            Hi Everyone
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            +Great day ahead
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi Everyone
        end
    end
    
    def testPatching_NeedMoreContext_NonEmptyFile
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
        end
    end
    
    def testPatching_NeedMoreContext_NonEmptyFile_noSection
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
        end
    end
    
    def testPatching_startOfFile
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [START OF FILE]
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
            Yo
        end
    end
    
    def testPatching_startOfFile_morePatches
        writeFile .drew.txt %%
            Yo
            Spring
            Summer
            Fall
            Winter
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [START OF FILE]
            +Hi
            @@ Spring
            -Fall
            +Thanksgiving
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
            Yo
            Spring
            Summer
            Thanksgiving
            Winter
        end
    end

    def testPatching_endOfFile
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [END OF FILE]
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            Hi
        end
    end
    
    def testPatching_endOfFile_morePatches
        writeFile .drew.txt %%
            Line A
            Line B
            Line C
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
             Line A
            -Line B
            +Line Blueberry
            @@ [END OF FILE]
            +Line D
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Line A
            Line Blueberry
            Line C
            Line D
        end
    end
    # testPatching_endOfFile_morePatches, exit

    def testPatchingAddInMiddle
        # any number of @@ does not break
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi Everyone
            How are you?
            Great
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
             Hi Everyone
             How are you?
            +hmm...
             Great
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi Everyone
            How are you?
            hmm...
            Great
        end
    end
    
    def testPatchingLol
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Hi
            Hello
            }
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            -}
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
            Hello
            }
        end
    end
    
    def testPatchingSameLine
        writeFile .drew.txt %%
            Line 1
            Line 2
            Line 3
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ Line 2
            -Line 2
            +New Line 2
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Line 1
            New Line 2
            Line 3
        end
    end
    # testPatchingSameLine, exit
    
    def testPatchingHmm1
        writeFile .drew.txt %%
            Number 1
            Hi
            Hello
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ Hi
            -Hello
            +Hello world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Number 1
            Hi
            Hello world
        end
    end
    
    def testPatchingHmm2
        writeFile .drew.txt %%
            Number 0
            Hello
            Number 1
            Hi
            Hello
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ Hi
            -Hello
            +Hello world
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Number 0
            Hello
            Number 1
            Hi
            Hello world
        end
    end
    def testPatching_AmbiguousButOk
        writeFile .drew.txt %%
            Welcome
            A
            B
            C
            A
            B
            C
            A
            B
            C
            The End
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            -A
            -B
            -C
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Welcome
            A
            B
            C
            A
            B
            C
            The End
        end
    end
    def testPatching_AmbiguousButNotOk
        writeFile .drew.txt %%
            Welcome
            A
            B
            C
            ***
            A
            B
            C
            $$$
            A
            B
            C
            ...
            The End
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            -A
            -B
            -C
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Welcome
            A
            B
            C
            ***
            A
            B
            C
            $$$
            A
            B
            C
            ...
            The End
        end
    end
    
    def testPatching_AmbiguousButSectionSoOK
        writeFile .drew.txt %%
            Welcome
            A
            B
            C
            ***
            A
            B
            C
            $$$
            A
            B
            C
            ...
            The End
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ Welcome
            -A
            -B
            -C
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Welcome
            ***
            A
            B
            C
            $$$
            A
            B
            C
            ...
            The End
        end
    end
    
    def testPatching_StartAndEnd
        writeFile .drew.txt %%
            Some Lines
            Are Here
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [START OF FILE]
            +Begin....
            +...
            @@ [END OF FILE]
            +...
            +...End
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Begin....
            ...
            Some Lines
            Are Here
            ...
            ...End
        end
    end
    def testPatching_StartWithFind
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [START OF FILE]
            -Yo
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
        end
    end
    
    def testPatching_EndWithFind
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ [END OF FILE]
            -Yo
            +Hi
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
        end
    end
    
    
    def testPatching_trailingAt
        writeFile .drew.txt %%
            Yo
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            -Yo
            +Hi
            @@
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Hi
        end
    end
    
    # def testPatching_RemoveBlock
    #     writeFile .drew.txt %%
    #         A
    #         B
    #         C
    #         D
    #         E
    #         F
    #         G
    #         H
    #         I
    #         J
    #     end
    #     var commandHistory []
    #     string
    #         PATCH FILE: drew.txt
    #         @@ [REMOVE BLOCK START]
    #         -C
    #         @@ [REMOVE BLOCK END]
    #         -F
    #         END PATCH
    #     end
    #     parseCommands
    #     processCommands it commandHistory
    #     readFile .drew.txt
    #     assertEq it %%
    #         A
    #         B
    #         G
    #         H
    #         I
    #         J
    #     end
    # end
    
    def testPatching_AddAfterSection
        writeFile .drew.txt %%
            Number 1
            Hi
            Hello
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ Hi
            +
            +New Stuff
            +Here
            +
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Number 1
            Hi

            New Stuff
            Here

            Hello
        end
    end
    
    def testPatching_ambiguousButNoOp
        writeFile .drew.txt %%
            Yo
            A
            Yo
            B
            Yo
            C
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            -Yo
            +Yo
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        assertEq (commandHistory at 1, at error) ""
        readFile .drew.txt
        assertEq it %%
            Yo
            A
            Yo
            B
            Yo
            C
        end
    end
    
    # we removed required order because gpt-4.1 wasn't always giving patch sections in correct order
    # howevever if we get an empty diff in one or more patch sections
    # include that context for the next patch
    
    # open question, should we include it for subsequent patches?
    def testPatching_emptyContextStacks
        deleteFile .delme.txt
        writeFile .drew.txt %%
            Yo
            func sayHi() {
                // hey
                println("hi")
            }
            func sayCool() {
                // cool
                println("cool")
            }
            func sayBye() {
                // cya
                println("bye")
            }
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@ foo
            @@
                 func sayCool() {
            @@
                 }
            @@
            +// some comments
            +// here
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        readFile .drew.txt
        assertEq it %%
            Yo
            func sayHi() {
                // hey
                println("hi")
            }
            func sayCool() {
                // cool
                println("cool")
            }
            // some comments
            // here
            func sayBye() {
                // cya
                println("bye")
            }
        end
    end
    testPatching_emptyContextStacks, exit
    exit
    
    def testPatching_commandDebug
        writeFile .drew.txt %%
            Hello
            World
        end
        var commandHistory []
        string
            PATCH FILE: drew.txt
            @@
            -World
            +Earth
            END PATCH
        end
        parseCommands
        processCommands it commandHistory
        assertEq (commandHistory at 1, at error) ""
        say commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello
            Earth
        end
    end
    
    def testPatching_see_file_block
        writeFile .drew.txt %%
            Hello
            World
            func foo
                some code
                here
            end
            cool
        end
        var commandHistory []
        string
            SEE FILE BLOCK: drew.txt @@ func foo
        end
        parseCommands
        processCommands it commandHistory
        updateLiveHistory commandHistory
        assertEq (commandHistory at 1, at error) null
        say commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello
            World
            func foo
                some code
                here
            end
            cool
        end
        assertEq commandHistory at 1, at output, string
            func foo
                some code
                here
            end
        end
    end
    # testPatching_see_file_block, exit
    
    def testPatching_remove_file_block
        writeFile .drew.txt %%
            Hello
            World
            func foo
                some code
                here
            end
            cool
        end
        var commandHistory []
        string
            REMOVE FILE BLOCK: drew.txt @@ func foo
        end
        parseCommands
        processCommands it commandHistory
        updateLiveHistory commandHistory
        assertEq (commandHistory at 1, at error) null
        say commandHistory
        readFile .drew.txt
        assertEq it %%
            Hello
            World
            cool
        end
        assertEq commandHistory at 1, at output, string
            *** drew.txt updated successfully ***
        end
    end
    
    def testCommandHistory
        var commandHistory []
        commandHistory push {
            name "llmResponse"
            content "test1"
        }
        commandHistory push {
            name "llmResponse"
            content "test2"
        }
        #Interesting1
        var newCommandHistory updateLiveHistory commandHistory
        assertEq len newCommandHistory, 1
    end

    def testCommandFlow
        writeFile .testFile1.txt %%
            Hi all
        end
        writeFile .testFile2.txt %%
            Yo
        end
        var commandHistory []
        parseCommands string
            SEE FILE: testFile1.txt
            SEE FILE: testFile2.txt
            PATCH FILE: testFile1.txt
            -Hi all
            +Hi everyone
            END PATCH
        end
        processCommands it commandHistory
        let commandHistory updateLiveHistory commandHistory
        displayHistory commandHistory
        as theDisplayHistory
        assertEq theDisplayHistory string
            ******** Latest States of Your Output and Commands Ran ********
            Note, here is a collection of commands run plus their latest state.
            So if you see a file or directory or snippet or block here it will always be the latest known version of the file/dir/snippet/block.
            You do not need to request the same file again.
            If you see a shell output here it's the output of the last time it ran.
            You may need to run the shell output again, for example if you want to rerun a test after changing a file.
            ********


            *** The following command was issued
            SEE FILE: testFile1.txt
            *** Here is the response
            Hi everyone
            *** End resposne


            *** The following command was issued
            SEE FILE: testFile2.txt
            *** Here is the response
            Yo
            *** End resposne


            *** The following command was issued
            PATCH FILE: testFile1.txt
            -Hi all
            +Hi everyone
            END PATCH
            *** Here is the response
            *** testFile1.txt updated successfully ***
            *** End resposne


            ******** End History ********
        end

    end

    def skip_testPatching1
        deleteFile .delme.txt
        writeFile .drew.txt %%
            def SomeFunc
                if x is 3
                    say "wow"
                end

                if x is 4
                    say "yay1"
                    say "yay2"
                    say "yay3"
                    say "yay4"
                    say "yay5"
                end
            end
            def OtherFunc
                if x is 3
                    say "wow"
                end

                if x is 4
                    say "yay1"
                    say "yay2"
                    say "yay3"
                    say "yay4"
                    say "yay5"
                    say "yay6"
                    say "yay7"
                    say "yay8"
                end
            end
        end

        var commandHistory []
        string
            PATCH FILE: drew.txt @@ def OtherFunc @@ if x
                     say "yay2"
            -        say "yay3"
            -        say "yay4"
                     say "yay5"
            +        say "yay5.1"
            +        say "yay5.2"
            +        say "yay5.3"
                     say "yay6"
            -        say "yay7"
            -        say "yay8"
            +        say "ok!"
            +        say "ok2!"
                 end
            END PATCH
            PATCH FILE: delme.txt
            +hello world
            +how things
            END PATCH
        end
        parseCommands
        as parsed
        assertSame parsed fromJson string
            [
                {
                    "argLine": "drew.txt @@ def OtherFunc @@ if x",
                    "body": "         say \"yay2\"\n-        say \"yay3\"\n-        say \"yay4\"\n         say \"yay5\"\n+        say \"yay5.1\"\n+        say \"yay5.2\"\n+        say \"yay5.3\"\n         say \"yay6\"\n-        say \"yay7\"\n-        say \"yay8\"\n+        say \"ok!\"\n+        say \"ok2!\"\n     end",
                    "name": "PATCH FILE",
                    "raw": "PATCH FILE: drew.txt @@ def OtherFunc @@ if x"
                },
                {
                    "argLine": "delme.txt",
                    "body": "+hello world\n+how things",
                    "name": "PATCH FILE",
                    "raw": "PATCH FILE: delme.txt"
                }
            ]
        end
        say "Parsed Commands: " parsed
        processCommands parsed commandHistory
    end

    __state at Vars, each k v
        if k startsWith "test"
             say "Testing" k
             __state at Vars, at %k
             call
        end
    end
    showTestOutput
end

