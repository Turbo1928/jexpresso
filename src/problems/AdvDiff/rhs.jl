include("../AbstractProblems.jl")

include("../../kernel/abstractTypes.jl")
include("../../kernel/infrastructure/element_matrices.jl")
include("../../kernel/mesh/mesh.jl")
include("../../kernel/mesh/metric_terms.jl")
include("../../kernel/basis/basis_structs.jl")

function build_rhs(SD::NSD_2D, QT::Inexact, AP::Adv2D, qp, ψ, dψ, ω, mesh::St_mesh, metrics::St_metrics, T)

    qnel = zeros(T, mesh.ngl,mesh.ngl,mesh.nelem,3)

    N  = mesh.nop
    QN = N + 1
    MN = N + 1
    
    #rhs_el = zeros(mesh.ngl,mesh.ngl,mesh.nelem)
    rhs_el = zeros(mesh.ngl*mesh.ngl,mesh.nelem)
    for iel=1:mesh.nelem
        for i=1:mesh.ngl
            for j=1:mesh.ngl
                m = mesh.connijk[i,j,iel]

                qnel[i,j,iel,1] = qp.qn[m,1]
                qnel[i,j,iel,2] = qp.qn[m,2]
                qnel[i,j,iel,3] = qp.qn[m,3]
                
            end
        end
    end
    #
    # Note on the evaluation of  ∫rhsᵉ dξ ≈ ∑_k(w_k Jel_k ψ_i,k)rhs_k = wᵢJᵉᵢψᵢᵢrhsᵉᵢ:
    #
    # Note that the quadrature sum was removed by means of the cardinality of the basis function 
    # in the tensor-product approach! See Sectopn 17.1.1 of Giraldo's book.
    #
    for iel=1:mesh.nelem
        for i=1:MN
            for j=1:MN
                m = i + (j-1)*MN
                
                u  = qnel[i,j,iel,2]
                v  = qnel[i,j,iel,3]
                
                dqdξ = 0
                dqdη = 0
                for k = 1:MN
                    dqdξ = dqdξ + dψ[k,i]*qnel[k,j,iel,1]
                    dqdη = dqdη + dψ[k,j]*qnel[i,k,iel,1]
                end
                dqdx = dqdξ*metrics.dξdx[i,j,iel] + dqdη*metrics.dηdx[i,j,iel]
                dqdy = dqdξ*metrics.dξdy[i,j,iel] + dqdη*metrics.dηdy[i,j,iel]

                rhs_el[m, iel] = ω[i]*ω[j]*metrics.Je[i,j,iel]*(u*dqdx + v*dqdy)
                #rhs_el[i,j,iel] = ω[i]*ω[j]*metrics.Je[i,j,iel]*(u*dqdx + v*dqdy)
            end
        end
    end
    
    #
    # Add diffusion ν∫∇ψ⋅∇q (ν = const for now)
    #
    ν = 0.1

    #rhsdiffξ_el = Array{T, 2}(undef, mesh.ngl*mesh.ngl, mesh.nelem)
    #rhsdiffη_el = Array{T, 2}(undef, mesh.ngl*mesh.ngl, mesh.nelem)
    #rhsdiffξ_el = zeros(mesh.ngl*mesh.ngl, mesh.nelem)
    #rhsdiffη_el = zeros(mesh.ngl*mesh.ngl, mesh.nelem)
    #rhsdiffξ_el = zeros(mesh.npoin*mesh.npoin, mesh.nelem)
    #rhsdiffη_el = zeros(mesh.npoin*mesh.npoin, mesh.nelem)
    
    for iel=1:mesh.nelem
        
        #rhsdiffξ_el = zeros(mesh.ngl*mesh.ngl, mesh.nelem)
        #rhsdiffη_el = zeros(mesh.ngl*mesh.ngl, mesh.nelem)
        for l = 1:QN, k = 1:QN
            ωkl  = ω[k]*ω[l]
            Jkle = metrics.Je[k, l, iel]
            
            dqdξ, dqdη = 0.0, 0.0
            for i = 1:MN
                dqdξ = dqdξ + dψ[i,l]*qnel[i,k,iel,1]
                dqdη = dqdη + dψ[i,k]*qnel[l,i,iel,1]
            end
            dqdx = dqdξ*metrics.dξdx[l,k,iel] + dqdη*metrics.dηdx[l,k,iel]
            dqdy = dqdξ*metrics.dξdy[l,k,iel] + dqdη*metrics.dηdy[l,k,iel]
            
            ∇ξ∇q_kl = metrics.dξdx[k,l,iel]*dqdx + metrics.dξdy[k,l,iel]*dqdy
            ∇η∇q_kl = metrics.dηdx[k,l,iel]*dqdx + metrics.dηdy[k,l,iel]*dqdy
            
            for i = 1:MN
                Iξ = i + (l - 1)*(N + 1)
                Iη = k + (i - 1)*(N + 1)
                
                hll,     hkk     =  ψ[l,l],  ψ[k,k]
                dhik_dξ, dhil_dη = dψ[i,k], dψ[i,l]
                
                rhsdiffξ_el[Iξ,iel] += ωkl*Jkle*dhik_dξ*hll*∇ξ∇q_kl*ν
                rhsdiffη_el[Iη,iel] += ωkl*Jkle*hkk*dhil_dη*∇η∇q_kl*ν
            end
        end
    end
    
    #@info size(rhsdiffξ_el)
    #show(stdout, "text/plain", rhsdiffξ_el[:,1])
    
    return rhs_el
    #return rhs_el + rhsdiffξ_el #+ rhsdiffη_el
end


function build_rhs(SD::NSD_1D, QT::Inexact, PT::Wave1D, mesh::St_mesh, metrics::St_metrics, M, el_mat, f)

    #
    # Linear RHS in flux form: f = u*q
    #  
    rhs = zeros(mesh.npoin)
    fe  = zeros(mesh.ngl)
    for iel=1:mesh.nelem
        for i=1:mesh.ngl
            I = mesh.conn[i,iel]
            fe[i] = f[I]
        end
        for i=1:mesh.ngl
            I = mesh.conn[i,iel]
            for j=1:mesh.ngl
                rhs[I] = rhs[I] - el_mat.D[i,j,iel]*fe[j]
            end
        end
    end

    # M⁻¹*rhs where M is diagonal
    rhs .= rhs./M
    
    return rhs
end

function build_rhs(SD::NSD_1D, QT::Exact, PT::Wave1D, mesh::St_mesh, metrics::St_metrics, M, el_mat, f)

    #
    # Linear RHS in flux form: f = u*q
    #
    
    rhs = zeros(mesh.npoin)
    fe  = zeros(mesh.ngl)
    for iel=1:mesh.nelem
        for i=1:mesh.ngl
            I = mesh.conn[i,iel]
            fe[i] = f[I]
        end
        for i=1:mesh.ngl
            I = mesh.conn[i,iel]
            for j=1:mesh.ngl
                rhs[I] = rhs[I] - el_mat.D[i,j,iel]*fe[j]
            end
        end
    end
    
    # M⁻¹*rhs where M is not full
    rhs = M\rhs
    
    return rhs
end
