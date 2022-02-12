#
# This file contains all the structs definitions
# S. Marras, Feb 2022
# 
"""
    struct st_legendrea{T<:Real}
        legendre  :: T
        dlegendre :: T
        q         :: T # q  = legendre(p+1)  - legendre(p-1)
        dq        :: T # dq = dlegendre(p+1) - dlegendre(p-1)
    end
"""

struct st_legendre{T<:Float64}
    legendre  :: T
    dlegendre :: T
    q         :: T # q  = legendre(p+1)  - legendre(p-1)
    dq        :: T # dq = dlegendre(p+1) - dlegendre(p-1)  
end

function (l::st_legendre)()
    
    
   return [l.legendre,l.dlegendre]
end



struct st_lgl{T<:Float64}
    lgl    :: T
    weight :: T
end


function f_lgl(lgl::st_lgl, p::int, ksi::T, w::T)

"""
2  Evaluate recursion, the Legendre polynomial of order p
  and its Derivatives at coordinate x
 
  L_{p}  --> legendre of order p
  L'_{p} --> dlegendr of order p
  
  and
 
  q  = L_{p+1}  -  L_{p-1}
  q' = L'_{p+1} -  L'_{p-1} 
  
  Algorithm 22+24 of Kopriva's book
  
"""

    size    = p + 1;
    ksi     = zeros(T, size)
    weights = zeros(T, size)
    
    #LGL nodes
    LegendreGaussLobattoNodesAndWeights(lgl, nop);
    
    #LG nodes
    #LegendreGaussNodesAndWeights(lgl, nop);

    return lgl;
end

