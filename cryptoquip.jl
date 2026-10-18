# CryptoQUIP Interactive Solver in Julia
# Features:
# - CIPHER=PLAIN replaces all occurrences (e.g. U=W)
# - Comma-separated inputs (e.g. U=W, K=E)
# - 'F' to toggle display of letter frequencies
# - 'Z' to undo the most recent substitution
# - 'C' to clear/reset all substitutions
# - '0' to exit, display the result, and optionally save to a text file

using Dates

function get_decoded_string(coded_string::String, substitutions::Vector{Char}; styled::Bool=false)
    STYLE_DECODED = "\e[1;36m"
    STYLE_RESET   = "\e[0m"

    result = IOBuffer()
    for ch in coded_string
        if 'A' <= ch <= 'Z'
            idx = ch - 'A' + 1
            plain_char = substitutions[idx]
            if plain_char != ' '
                if styled
                    print(result, "$(STYLE_DECODED)$(plain_char)$(STYLE_RESET)")
                else
                    print(result, plain_char)
                end
            else
                print(result, ch)
            end
        else
            print(result, ch)
        end
    end
    return String(take!(result))
end

function run_cryptoquip()
    alphabet = collect('A':'Z')
    substitutions = fill(' ', 26)

    # State toggle for frequency display
    show_frequencies = false

    # History stack for undo ('Z')
    history = Vector{Vector{Char}}()

    STYLE_ALERT = "\e[1;33m"   # Bold Yellow for alerts
    STYLE_RESET = "\e[0m"

    println("==================================================")
    println("          WELCOME TO CRYPTOQUIP SOLVER            ")
    println("==================================================")

    print("Enter the coded CryptoQUIP puzzle string:\n> ")
    coded_string = uppercase(strip(readline()))

    if isempty(coded_string)
        println("Error: Empty input string. Exiting.")
        return
    end

    # Pre-calculate cipher letter frequencies from the input string
    freq_map = zeros(Int, 26)
    for ch in coded_string
        if 'A' <= ch <= 'Z'
            freq_map[ch - 'A' + 1] += 1
        end
    end

    while true
        # Display current substitution table (spaced for 2-digit frequencies)
        println("\n--- Current Substitution Key ---")
        
        # Cipher Row
        cipher_row = join([lpad(c, 3) for c in alphabet], "")
        println("Cipher: ", cipher_row)

        # Optional Frequency Row
        if show_frequencies
            freq_row = join([lpad(freq_map[i], 3) for i in 1:26], "")
            println("Freq:   ", freq_row)
        end

        # Plain Substitution Row
        plain_row = join([lpad(substitutions[i] == ' ' ? '-' : substitutions[i], 3) for i in 1:26], "")
        println("Plain:  ", plain_row)

        # Render current progress with highlighted solved letters
        println("\nProgress: ", get_decoded_string(coded_string, substitutions; styled=true))
        println("--------------------------------")

        print("\nEnter substitution ('U=W'), 'F' (toggle freq), 'Z' (undo), 'C' (clear), or '0' (exit):\n> ")
        raw_input = uppercase(strip(readline()))

        # Command: Exit
        if raw_input == "0"
            println("\nExiting solver cycle.")
            break
        end

        # Command: Toggle frequency display
        if raw_input == "F"
            show_frequencies = !show_frequencies
            status = show_frequencies ? "ON" : "OFF"
            println("$(STYLE_ALERT)Frequency display toggled $(status).$(STYLE_RESET)")
            continue
        end

        # Command: Undo last change
        if raw_input == "Z"
            if !isempty(history)
                substitutions = pop!(history)
                println("$(STYLE_ALERT)Undid the most recent substitution.$(STYLE_RESET)")
            else
                println("$(STYLE_ALERT)Nothing to undo - history is empty.$(STYLE_RESET)")
            end
            continue
        end

        # Command: Clear all substitutions
        if raw_input == "C"
            if any(substitutions .!= ' ')
                push!(history, copy(substitutions))
                fill!(substitutions, ' ')
                println("$(STYLE_ALERT)Cleared all substitutions. (Type 'Z' to restore).$(STYLE_RESET)")
            else
                println("$(STYLE_ALERT)Substitution table is already empty.$(STYLE_RESET)")
            end
            continue
        end

        # Process letter mappings (supports comma-separated list: "U=W, K=E")
        entries = split(raw_input, ",")
        valid_entries = 0
        state_saved = false

        for entry in entries
            m = match(r"^\s*([A-Z])\s*=\s*([A-Z])\s*$", strip(entry))
            if m !== nothing
                if !state_saved
                    push!(history, copy(substitutions))
                    state_saved = true
                end

                cipher_char = m.captures[1][1]
                plain_char  = m.captures[2][1]

                idx = cipher_char - 'A' + 1
                substitutions[idx] = plain_char

                occ_count = freq_map[idx]
                println("Replaced all $(occ_count) instances of '$(cipher_char)' with '$(plain_char)'")
                valid_entries += 1
            end
        end

        if valid_entries == 0
            println("\e[31mInvalid command! Enter CIPHER=PLAIN (e.g., U=W), 'F' to toggle freqs, 'Z' to undo, 'C' to clear, or '0' to exit.\e[0m")
        end
    end

    # Print final output on terminal
    final_decoded = get_decoded_string(coded_string, substitutions; styled=false)
    println("\n================ FINAL DECODED RESULT ================")
    println(get_decoded_string(coded_string, substitutions; styled=true))
    println("======================================================")

    # Option to save to text file
    print("\nDo you want to save this solution to a text file? (y/N):\n> ")
    save_choice = lowercase(strip(readline()))

    if save_choice == "y" || save_choice == "yes"
        date_stamp = Dates.format(now(), "yymmdd")
        default_filename = "cqSolution-$(date_stamp).txt"

        print("Enter file name (press Enter for default '$(default_filename)'):\n> ")
        custom_name = strip(readline())
        filename = isempty(custom_name) ? default_filename : custom_name

        if !endswith(lowercase(filename), ".txt")
            filename *= ".txt"
        end

        open(filename, "w") do f
            println(f, "==================================================")
            println(f, "             CRYPTOQUIP PUZZLE SOLUTION           ")
            println(f, "             Saved: ", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
            println(f, "==================================================\n")

            println(f, "ORIGINAL CIPHER TEXT:")
            println(f, coded_string, "\n")

            println(f, "DECODED PLAIN TEXT:")
            println(f, final_decoded, "\n")

            println(f, "SUBSTITUTION KEY:")
            println(f, "Cipher: ", join([lpad(c, 3) for c in alphabet], ""))
            if show_frequencies
                println(f, "Freq:   ", join([lpad(freq_map[i], 3) for i in 1:26], ""))
            end
            println(f, "Plain:  ", join([lpad(substitutions[i] == ' ' ? '-' : substitutions[i], 3) for i in 1:26], ""), "\n")

            println(f, "ACTIVE MAPPINGS:")
            for i in 1:26
                if substitutions[i] != ' '
                    println(f, "  $(alphabet[i]) -> $(substitutions[i])")
                end
            end
        end

        println("$(STYLE_ALERT)Successfully saved solution to '$(filename)'!$(STYLE_RESET)")
    end
end

run_cryptoquip()