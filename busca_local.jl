include("tools.jl")

IEdge = Graphs.IEdge
const SimpleGraph = GenericGraph{Int,IEdge,Array{Int},Vector{IEdge},Vector{Vector{IEdge}}}

function crea_grafo(mis_indices; is_directed=false)
    n = length(mis_indices)

    SimpleGraph(is_directed,
                       mis_indices,  # vertices
                       Graphs.IEdge[],   # edges
                       Graphs.multivecs(Graphs.IEdge, n), # finclist
                       Graphs.multivecs(Graphs.IEdge, n), # binclist
       Dict{Int, Int}()) # indices (not used for simple graph)

end

function genLocalGrid(matriz, la, lb)
    rows, cols = size(matriz)

    mis_indices = Int[]

    for x in la
        for y in lb
            i = (x-1)*cols + y

            push!(mis_indices, i)

        end
        
    end

    grafo = crea_grafo(mis_indices, is_directed = false)
    pesos = []

    for i in mis_indices
        if i > 1 && i%rows != 1 && matriz[i-1] == 1
            add_edge!(grafo, i, i-1)
            push!(pesos, 1 + 10rand())
        end
        if i > rows && matriz[i-cols] == 1
            add_edge!(grafo, i, i-cols)
            push!(pesos, 1 + 10rand())
        end
    end


    return grafo, mis_indices
end

perro =nothing
function rutaCortaLocal(matriz, h, inicio_local, l)
    la = l[1]
    lb = l[2]

    rows, cols = size(matriz)

    grafo, mis_indices = genLocalGrid(matriz, la, lb)

    println(mis_indices)
    println(inicio_local)

    final_local = mis_indices[1]
    d_min = Inf

    for i in mis_indices
        if matriz[i] == 0
            continue
        end

        x = 1 + div(i, cols)
        y = i%rows
        d = abs(y - h(x))

        if d <= d_min
            d_min = d
            final_local = i
        end
    end

    println(">>>> ", length(mis_indices))
    r = shortest_path(grafo, ones(length(mis_indices)), inicio_local, final_local, h)

    return r, r[end]
end

function rutaCortaLocal(grafo, h, inicio_global, final_global, radio)
    rows, cols = size(grafo)
    a = radio-1
    b = div(radio, 2)

    index2coor(i) =  [1+div(i, cols), i%rows]


    inicio_local = inicio_global

    ruta = Array{Int}([])

    while inicio_local != final_global       
        x, y = index2coor(inicio_local)


        la1 = x - a < 1 ? 1 : x-a
        la2 = x + a > cols ? cols : x + a
        
        lb2 = y + b > rows ? rows : y + b

        la = la1:la2
        lb = y:lb2

        ruta_local, siguiente_inicio_local = rutaCortaLocal(grafo, h, inicio_local, (la, lb))

        inicio_local = siguiente_inicio_local

        ruta = [ruta; ruta_local]
    end
end

function experimento2(rows, cols, ini, fin, puntos)
    println("Iniciando")

    radio = 7

    _, distancias, nodos = genGrid(rows, cols, p = 1)
    
    
    index2coor(i) =  [1+div(i, cols), i%rows]
    
    inicio_global  = ini
    destino_global = fin

    nodos[ini] = 1
    nodos[fin] = 1
    
    p  = puntos[1,:]
    p2 = puntos[2,:]

    inicio  = index2coor(ini)
    destino = index2coor(fin)

    # interpilar polinomio con 4 puntos
    data = [inicio';
            p';
            p2';
            destino']
    
    xData = data[:,1]
    yData = data[:,2]

    
    coef = coeffts(xData,yData)
    
    rutaGPS(x::Int, coef_::Array{Float64} = coef, xData_::Array{Float64}=xData) = evalPoly(coef_, xData_, x)
    
    pol = zeros(Int, rows*cols)

    for i = 1:rows*cols
        x = 1 + div(i, cols)
        y = i%rows
        d = abs(y - rutaGPS(x)) #norm( a - [a[1], rutaGPS(a[1])])
        
        if d > 1
            pol[i] = round(Int, 100000d)            
        end

    end
    
    h(t::Int) = pol[t]
    
    println("Buscando ruta...")
    
    # ruta más corta usando A*
    #-------------------------------------------- 
    ruta_corta = rutaCortaLocal(nodos, h, inicio_global, destino_global, radio)
    #-------------------------------------------- 
    nodos[ini] = 2
    nodos[fin] = 2

   for i in r
        try
        nodos[target(i)]= 3 # color
        catch
        end
    end

    ph = heatmap(nodos)
    x =1:cols
    plot!(x, rutaGPS, linewidth=5)

       
    
end

function test2()

    rows = 50
    cols = 50

    ini = 1
    fin = rows * cols - 8
    puntos = [
         5.0  23.0;
        14.0   5.0
    ]

    experimento2(rows, cols, ini, fin, puntos)
end

test2()