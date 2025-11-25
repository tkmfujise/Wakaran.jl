module Wakaran


using InteractiveUtils


export @ls, @dir


struct List
    propertynames::NTuple
    methodswith::Vector{Method}
end


struct ModuleList
    names::Vector{Symbol}
end


function Base.show(io::IO, list::List)
    println(io, colorize("Propertynames:", bold=true, underline=true, fg=:blue))
    if length(list.propertynames) > 0
        for prop in list.propertynames
            println(io, " * " * colorize("$prop", fg=:blue))
        end
    else
        println(io, " (nothing)")
    end

    println(io, "\n")
    println(io, colorize("Methodswith:", bold=true, underline=true, fg=:red))
    if length(list.methodswith) > 0
        for method in list.methodswith
            println(io, " + " * colorize("$(method)", fg=:red))
        end
    else
        println(io, " (nothing)")
    end
end


function Base.show(io::IO, module_list::ModuleList)
    println(io, colorize("Names:", bold=true, underline=true, fg=:green))
    if length(module_list.names) > 0
        for name in module_list.names
            println(io, " - " * colorize("$name", fg=:green))
        end
    else
        println(io, " (nothing)")
    end
end


ANSI_FG_COLORS = Dict(
    :black   => 30,
    :red     => 31,
    :green   => 32,
    :yellow  => 33,
    :blue    => 34,
    :magenta => 35,
    :cyan    => 36,
    :white   => 37,
    )
ANSI_BG_COLORS = Dict(
    :black   => 40,
    :red     => 41,
    :green   => 42,
    :yellow  => 43,
    :blue    => 44,
    :magenta => 45,
    :cyan    => 46,
    :white   => 47,
    )


"""
colorize(text; fg=:red, bg=:nothing, bold=false)
COLORS: :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white
"""
function colorize(text::AbstractString; fg=:nothing, bg=:nothing, bold=false, underline=false)
    codes = String[]
    if bold
        push!(codes, "1")
    end
    if underline
        push!(codes, "4")
    end
    if fg != :nothing
        push!(codes, string(ANSI_FG_COLORS[fg]))
    end
    if bg != :nothing
        push!(codes, string(ANSI_BG_COLORS[bg]))
    end
    prefix = isempty(codes) ? "" : "\033[" * join(codes, ";") * "m"
    return prefix * text * "\033[0m"
end



function with_pager(f::Function, pager::AbstractString)
    before = haskey(ENV, "PAGER") ? ENV["PAGER"] : nothing
    try
        ENV["PAGER"] = pager
        return f()
    finally
        if isnothing(before)
            delete!(ENV, "PAGER")
        else
            ENV["PAGER"] = before
        end
    end
end


function show_as_less(x)
    tmp = tempname()
    before = haskey(ENV, "PAGER") ? ENV["PAGER"] : nothing
    open(tmp, "w") do io
        show(io, x)
    end
    with_pager("less -qR") do
        less(tmp)
    end
end


macro dir(target)
    quote 
        local target = $(esc(target))
        if target isa Module
            ModuleList(names(target))
        else
            List(
                propertynames(target),
                methodswith(target |> typeof; supertypes=true),
            )
        end
    end
end


"""
using Gtk4
win = Gtk4Window("Test")
@ls win 
"""
macro ls(target)
    quote 
        local list = @dir($(esc(target)))
        list |> show_as_less
    end
end


macro ls()
    quote
        varinfo()
    end
end



macro dir(target, name)
    quote
        local list = @dir($(esc(target)))
        local name = $(string(name))
        if list isa ModuleList
            filterednames = filter(x -> occursin(name, string(x)), list.names)
            ModuleList(filterednames)
        else
            filteredprops   = filter(p -> occursin(name, string(p)), list.propertynames)
            filteredmethods = filter(m -> occursin(name, string(m.name)), list.methodswith)
            List(filteredprops, filteredmethods)
        end
    end
end



end # end module
