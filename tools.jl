using Plots
using Graphs

gr(leg=false, dpi=1, size=(500,500))

function evalPoly(a,xData,x)
    n = length(xData)  # Degree of polynomial
    p = a[n]
    for k =1:n-1
        p = a[n-k] + (x -xData[n-k])*p
    end
    return p
end

function coeffts(xData,yData)
    m = length(xData)  # Number of data points
        
    a = copy(yData)
    
    for k=2:m
        a[k:m] = (a[k:m] - a[k-1]) ./ (xData[k:m] - xData[k-1])
    end
    
    return a
end


function genGrid(rows, cols, p = 0.8)
    nodosMatriz = zeros(Int32, rows, cols)

    # crea malla con nombre 1 a r*c
    #srand(543222423)
    grafo = simple_graph(rows * cols, is_directed = false)
    pesos = []

    for i = 1:rows*cols
        if rand() < p
            nodosMatriz[i] = 1
            
            if i > 1 && i%rows != 1 && nodosMatriz[i-1] == 1
                add_edge!(grafo, i, i-1)
                push!(pesos, 1 + 10rand())
            end
            if i > rows && nodosMatriz[i-cols] == 1
                add_edge!(grafo, i, i-cols)
                push!(pesos, 1 + 10rand())
                
            end
        end
    end
        
    return grafo, round.(Int32, pesos), nodosMatriz
end

function genGridFromFile(fname)
    nodosMatriz = readcsv(fname)
    rows, cols = size(nodosMatriz, 1, 2)
    
    # crea malla con nombre 1 a r*c
    grafo = simple_graph(rows * cols, is_directed = false)
    pesos = []

    for i = 1:rows*cols
        if i > 1 && i%rows != 1 && nodosMatriz[i-1] == 1
            add_edge!(grafo, i, i-1)
            push!(pesos, 1 +2rand())
        end
        if i > rows && nodosMatriz[i-cols] == 1
            add_edge!(grafo, i, i-cols)
            push!(pesos, 1 + 2rand())

        end
    end
        
    return grafo, round.(Int32, pesos), nodosMatriz
end

function recta(x, a, b)
    x1 = a[1]
    x2 = b[1]
    
    y1 = a[2]
    y2 = b[2]
    
    m = (y2 - y1) / (x2 - x1)
    
    return m * (x - x1) + y1
end

function rutaMasCorta(incio, fin, mapa, rutaGPS)
        return 1
end

function experimento(rows, cols, ini, fin, puntos)
    println("Iniciando")    

    
    grafo, distancias, nodos = genGrid(rows, cols)
    
    
    index2coor(i) =  [1+div(i, cols), i%rows]
    
    inicio  = index2coor(ini)
    destino = index2coor(fin)
    
    println(inicio)
    println(destino)
    
    nodos[ini] = 1
    nodos[fin] = 1
    
    p  = puntos[1,:]
    p2 = puntos[2,:]

    # interpilar polinomio con 4 puntos
    data = [inicio';
            p';
            p2';
            destino']
    
    xData = data[:,1]
    yData = data[:,2]

    
    coef = coeffts(xData,yData)
    
    rutaGPS(x) = evalPoly(coef, xData, x)
    
    
    h(t) = begin
            x, y =index2coor(t)
            d = norm( [x,y] - [x,rutaGPS(x)])
            if d > 1
                d = 1e7d
            end
            return round(Int32, d)
    end
    
    # ruta más corta usando A*
    r = shortest_path(grafo, distancias, ini, fin, h)
    
    
    nodos[ini] = 2
    nodos[fin] = 2
    

    
    
 
    @gif for i in r
       # for i in r
            try
            nodos[target(i)]= 3
            catch
            end
        #end
    
        ph = heatmap(nodos)
        x =1:cols
        plot!(x, rutaGPS, linewidth=5)
   
     end
    

    

    println("Fin")    
    
end