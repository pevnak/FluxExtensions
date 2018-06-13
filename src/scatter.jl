"""
    scatter(x::Matrix,k::Int)

    repeat each column of `x` k-times

    ```juliadoc
    x = [1 3; 2 4]
    julia> FluxExtensions.scatter(x, 3)

    2×6 Array{Int64,2}:
     1  1  1  3  3  3
     2  2  2  4  4  4
     ```
"""
function scatter(x::Matrix,k::Int)
  xx = similar(x,size(x,1),k*size(x,2))
  @inbounds for j in 1:size(x,2)
    for b in 1:k
      for i in 1:size(x,1)
        xx[i,(j-1)*k+b] = x[i,j]
      end
    end 
  end
  xx
end


"""
    gather(x,k::Int) 

    sum blocks of size k-columns

    ```juliadoc
    julia>  x = [ 1 1 1 3 3 3; 2 2 2 4 4 4]
    julia> FluxExtensions.gather(x,3)
    2×2 Array{Int64,2}:
     3   9
     6  12
    ```
"""
function gather(x,k::Int) 
  d, l = size(x,1), div(size(x,2),k)
  reshape(sum(reshape(x,d,k,l),2),d,l)
end

scatter(x::Flux.Tracker.TrackedMatrix, k::Int) = Flux.Tracker.track(scatter,x, k )
back(::typeof(scatter), Δ, x::AbstractMatrix, k) = Flux.Tracker.@back(x, gather(Δ, k))