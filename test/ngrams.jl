using Test
using FluxExtensions: NGramIterator, ngrams, string2ngrams, countngrams, mul, multrans, NGramStrings
@testset "ngrams" begin
	x = [1,3,5,2,6,8,3]
	b = 8 + 1

	slicer = (x,n) -> map(i -> x[(max(i-n+1,1):min(i,length(x)))],1:length(x)+n-1)
	indexes = (x,b) -> mapreduce(i -> i[2]*b^(i[1]-1), +, enumerate(reverse(x)))
	function idx2vec(i,n)
		o = zeros(Int,n)
		for v in i
			o[mod(v,n)+1] +=1
		end 
		o
	end
	@testset "testing ngrams on vector of Ints" begin 
		@test all(ngrams(x,3,b) .== map(x -> indexes(x,b),slicer(x,3)))
		@test all(ngrams(x,2,b) .== map(x -> indexes(x,b),slicer(x,2)))
		@test all(ngrams(x,1,b) .== map(x -> indexes(x,b),slicer(x,1)))
	end

	@testset "testing frequency of ngrams on vector of Ints and on Strings" begin 
			@test all(countngrams(x,3,b,10) .== idx2vec(map(x -> indexes(x,b), slicer(x,3)), 10))
			for s in split("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
				@test all(countngrams(s,3,256,10) .== idx2vec(ngrams(s,3,256), 10))
			end

			s = split("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
			@test all(countngrams(s,3,256,10) .== hcat(map(ss -> idx2vec(ngrams(ss,3,256), 10),s)...))
	end


	@testset "string2ngrams" begin
		@test size(string2ngrams(["","a"],3,2053)) == (2053,2)
	end

	@testset "ngrams" begin
		all(collect(NGramIterator(codeunits("hello"), 3, 257)) .== ngrams("hello", 3, 257))

		A = randn(4, 10)
		s = ["hello", "world", "!!!"]
		B = NGramStrings(s, 3, 256)
		@test all(mul(A , B) .≈ A*string2ngrams(s, 3, size(A, 2)))
		A = randn(5,3)
		@test all(multrans(A , B) .≈ A*transpose(string2ngrams(s, 3, size(A, 2))))
	end
end