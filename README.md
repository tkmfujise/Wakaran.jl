# Wakaran.jl

｡ﾟ(ﾟ´Д｀ﾟ)ﾟ｡ ＜  Julia... I don't get it!


## Demo Video

[![Demo](http://img.youtube.com/vi/jujx8mkVGXY/0.jpg)](https://www.youtube.com/watch?v=jujx8mkVGXY)


## Usage

```julia
julia> using Wakaran
```

### @dir target
```julia
julia> @dir Wakaran
Names:
 - @dir :: Wakaran.var"#@dir"
 - @ls :: Wakaran.var"#@ls"
 - Wakaran :: Module

julia> using Images

# Listing info of a Module
julia> @dir Images
Names:
 - .. :: typeof(..)
 - @colorant_str :: Colors.var"#@colorant_str"
 - @test_approx_eq_sigma_eps :: Images.var"#@test_approx_eq_sigma_eps"
 - ABGR :: UnionAll
 - ADIN99 :: UnionAll
 - ADIN99d :: UnionAll
 - ADIN99o :: UnionAll
 - AGray :: UnionAll
 ⋮

julia> img = RGB()

# Listing info of a variable
julia> @dir img
Supertypes:
 RGB{N0f8} <: AbstractRGB{N0f8} <: Color3{N0f8} <: ColorantNormed{N0f8, 3} <: Any

Propertynames:
 * r :: N0f8
 * g :: N0f8
 * b :: N0f8

Methodswith:
 + adjoint(c::Colorant) @ ColorTypes ~/.julia/packages/ColorTypes/vpFgh/src/operations.jl:51    
 + *(f::Real, c::Union{TransparentColor{C, T}, C} where {T, C<:Union{AbstractRGB{T}, AbstractGray{T}}}) @ ColorVectorSpace ~/.julia/packages/ColorVectorSpace/tLy1N/src/ColorVectorSpace.jl:246 
 + *(c::Union{TransparentColor{C, T}, C} where {T, C<:Union{AbstractRGB{T}, AbstractGray{T}}}, f::Real) @ ColorVectorSpace ~/.julia/packages/ColorVectorSpace/tLy1N/src/ColorVectorSpace.jl:247
 ⋮
```

### @dir target keyword
```julia
# Grep info of a Module
julia> @dir Images BGR
Names:
 - ABGR :: UnionAll
 - BGR :: UnionAll
 - BGRA :: UnionAll

# Grep info of a variable
julia> @dir img convert
Supertypes:
 RGB{N0f8} <: AbstractRGB{N0f8} <: Color3{N0f8} 
<: ColorantNormed{N0f8, 3} <: Any

Propertynames:
 (nothing)

Methodswith:
 + convert(::Type{C}, c::C) where C<:Colorant() @ ColorTypes ~/.julia/packages/ColorTypes/vpFgh/src/conversions.jl:72
 + convert(::Type{C}, c::Colorant) where C<:Colorant() @ ColorTypes ~/.julia/packages/ColorTypes/vpFgh/src/conversions.jl:73
 + convert(::Type{C}, c::Color, alpha) where C<:TransparentColor() @ ColorTypes ~/.julia/packages/ColorTypes/vpFgh/src/conversions.jl:78 
```

### @ls
`@ls` shows the result of `varinfo(imported=true)`.
```julia
julia> @ls
  name          size summary  
  ––––––– –––––––––– –––––––––
  Base               Module   
  Core               Module   
  Images  74.967 KiB Module   
  Main               Module   
  Wakaran  6.568 KiB Module   
  img        3 bytes RGB{N0f8}
```

### @ls target
`@ls target` shows the result of `@dir target` with less command.
```julia
julia> @ls Images

julia> @ls img
```


## Conclusion

(＊´▽｀＊) ＜ Now I understand.
