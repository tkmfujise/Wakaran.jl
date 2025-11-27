module Wakaran


using InteractiveUtils


export @ls, @dir


struct FieldName
    self::Symbol
    type::DataType

    FieldName(name::Tuple{Symbol, DataType}) = begin
        new(name[begin], name[end])
    end
end


struct List
    supertypes::Vector{Type}
    propertynames::Vector{FieldName}
    methodswith::Vector{Method}
end


struct ModuleList
    names::Vector{FieldName}
end


struct MethodArgComponent
    name::SubString{String}
    type::SubString{String}
end


function build_method_args(argstr::SubString{String})
    isempty(argstr) && return MethodArgComponent[]
    args = MethodArgComponent[]
    for a in split(String(argstr), ",") .|> strip
        if contains(a, "::")
            parts = split(a, "::")
            push!(args, MethodArgComponent(parts[1], parts[2]))
        else
            push!(args, MethodArgComponent(a, SubString("")))
        end
    end
    args
end


struct MethodComponent
    name::SubstitutionString
    args::Vector{MethodArgComponent}
    location::SubstitutionString


    # "AbstractChar(x::Number) @ Base char.jl:51"
    MethodComponent(method::Method) = begin
        s = repr(method)
        parts = split(s, " @ ")
        funpart = parts[1]
        source  = parts[2]

        m = match(r"^(.+?)\((.*)\)$", funpart)
        fname, argstr = begin
            if !isnothing(m)
                (m.captures[1], m.captures[2])
            else
                (funpart, SubString(""))
            end
        end

        new(fname, build_method_args(argstr), source)
    end
end


function Base.show(io::IO, list::List)
    println(io, colorize("Supertypes:", bold=true, underline=true, fg=:green))
    if length(list.supertypes) > 0
        println(io, " " * colorize(join(list.supertypes, " <: ")))
    else
        println(io, " (nothing)")
    end

    println(io, "")
    println(io, colorize("Propertynames:", bold=true, underline=true, fg=:blue))
    if length(list.propertynames) > 0
        for name in list.propertynames
            println(io, " * " * colorize("$(name.self)", fg=:blue) * " :: " * "$(name.type)")
        end
    else
        println(io, " (nothing)")
    end

    println(io, "")
    println(io, colorize("Methodswith:", bold=true, underline=true, fg=:red))
    if length(list.methodswith) > 0
        for method in list.methodswith
            println(io, " + " * colorize(method))
        end
    else
        println(io, " (nothing)")
    end
end


function Base.show(io::IO, module_list::ModuleList)
    println(io, colorize("Names:", bold=true, underline=true, fg=:green))
    if length(module_list.names) > 0
        for name in module_list.names
            println(io, " - " * colorize("$(name.self)", fg=:green) * " :: " * "$(name.type)")
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
    :gray    => 90,
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
    :gray    => 100,
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


function colorize(m::MethodComponent)
    colorize(m.name, fg=:red) *
    "(" *
    (colorize.(m.args) |> x -> join(x, ", ")) *
    ") " *
    colorize("@ $(m.location)", fg=:gray)
end


function colorize(method::Method)
    # colorize(repr(method), fg = :red)
    MethodComponent(method) |> colorize
end


function colorize(arg::MethodArgComponent)
    if isempty(arg.type)
        colorize(arg.name, fg=:blue)
    else
        colorize(arg.name, fg=:blue) * "::" * arg.type
    end
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


function tuplefield(target, name)
    try
        tuple(name, typeof(getfield(target, name)))
    catch e
        tuple(name, Any)
    end
end


macro dir(target)
    quote 
        local target = $(esc(target))
        if target isa Module
            ModuleList(FieldName.(names(target) .|> n -> tuplefield(target, n)))
        else
            List(
                collect(target |> typeof |> supertypes),
                FieldName.(collect(propertynames(target) .|> x -> tuplefield(target, x))),
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
        varinfo(imported=true)
    end
end



macro dir(target, name)
    quote
        local list = @dir($(esc(target)))
        local name = $(string(name))
        if list isa ModuleList
            filterednames = filter(x -> occursin(name, string(x.self)), list.names)
            ModuleList(filterednames)
        else
            filteredprops   = filter(p -> occursin(name, string(p.self)), list.propertynames)
            filteredmethods = filter(m -> occursin(name, string(m.name)), list.methodswith)
            List(list.supertypes, filteredprops, filteredmethods)
        end
    end
end



end # end module
