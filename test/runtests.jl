using Wakaran
using Test

@testset "@dir 1" begin
    @test (@dir 1).supertypes == [Int64, Signed, Integer, Real, Number, Any]
    @test (@dir 1).propertynames |> isempty
    @test (@dir 1).methodswith |> !isempty
end

@testset "@dir Wakaran" begin
    @test (@dir Wakaran).names |> !isempty
end

@testset "@dir Test" begin
    @test (@dir Test).names |> !isempty
end

@testset "@dir 1 acos" begin
    @test (@dir 1 acos).supertypes == [Int64, Signed, Integer, Real, Number, Any]
    @test (@dir 1 acos).propertynames |> isempty
    @test (@dir 1 acos).methodswith |> v -> 
        all(m -> occursin("acos", string(m.name)), v)
end

@testset "@dir Wakaran ls" begin
    @test (@dir Wakaran ls).names |> v -> 
        all(s -> occursin("ls", string(s.self)), v)
end

@testset "@dir Test \"@test\"" begin
    @test (@dir Test "@test").names |> v -> 
        all(s -> occursin("@test", string(s.self)), v)
end


@testset "@ls" begin
    @test (@ls) |> !isempty
end

@testset "@ls 1" begin
    @test_skip (@ls 1) |> !isempty
end

@testset "@ls Wakaran" begin
    @test_skip (@ls Wakaran).names |> !isempty
end

@testset "@ls Test" begin
    @test_skip (@ls Test).names |> !isempty
end
