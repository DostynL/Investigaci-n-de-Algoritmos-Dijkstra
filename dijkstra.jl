# --------------------------------------------------------
#  Algoritmo de Dijkstra - Camino más corto en grafos
#  Implementado en Julia
#  Curso: Algoritmos y Estructuras de Datos
# --------------------------------------------------------

# ---------- Tipos y estructuras ---------------------------

"""
Representa un grafo dirigido/no-dirigido con pesos.
- `n`     : número de vértices (1-indexado)
- `adj`   : lista de adyacencia: adj[u] = [(v, peso), ...]
"""
struct Graph
    n::Int
    adj::Vector{Vector{Tuple{Int,Float64}}}
end
"""Crea un grafo vacío con `n` vértices."""
function Graph(n::Int)
    Graph(n, [Vector{Tuple{Int,Float64}}() for _ in 1:n])
end
"""Agrega una arista dirigida u a v con el peso dado."""
function add_edge!(g::Graph, u::Int, v::Int, weight::Float64)
    push!(g.adj[u], (v, weight))
end

"""Agrega una arista no dirigida (u ↔ v) con el peso dado."""
function add_undirected_edge!(g::Graph, u::Int, v::Int, weight::Float64)
    add_edge!(g, u, v, weight)
    add_edge!(g, v, u, weight)
end

# ---------- Cola de prioridad mínima (min-heap) -----------
"""
Min-heap simple de pares (distancia, nodo).
Usado internamente por Dijkstra para extraer el nodo
con menor distancia tentativamente conocida."""
mutable struct MinHeap
    data::Vector{Tuple{Float64,Int}}
end

MinHeap() = MinHeap(Vector{Tuple{Float64,Int}}())

function heap_push!(h::MinHeap, item::Tuple{Float64,Int})
    push!(h.data, item)
    _sift_up!(h, length(h.data))
end

function heap_pop!(h::MinHeap)::Tuple{Float64,Int}
    isempty(h.data) && error("Heap vacío")
    result = h.data[1]
    h.data[1] = h.data[end]
    pop!(h.data)
    isempty(h.data) || _sift_down!(h, 1)
    return result
end

Base.isempty(h::MinHeap) = isempty(h.data)

function _sift_up!(h::MinHeap, i::Int)
    while i > 1
        parent = i ÷ 2
        h.data[parent][1] <= h.data[i][1] && break
        h.data[parent], h.data[i] = h.data[i], h.data[parent]
        i = parent
    end
end

function _sift_down!(h::MinHeap, i::Int)
    n = length(h.data)
    while true
        smallest = i
        left, right = 2i, 2i + 1
        left  <= n && h.data[left][1]  < h.data[smallest][1] && (smallest = left)
        right <= n && h.data[right][1] < h.data[smallest][1] && (smallest = right)
        smallest == i && break
        h.data[i], h.data[smallest] = h.data[smallest], h.data[i]
        i = smallest
    end
end
# ---------- Algoritmo principal --------------------------

"""dijkstra(g, src) -> (dist, prev)

Calcula las distancias mínimas desde el vértice src a todos
los demás vértices del grafo g usando el algoritmo de Dijkstra.

# Retorna
- dist::Vector{Float64} — distancia mínima desde src a cada vértice.
  Inf si el vértice no es alcanzable.
- prev::Vector{Int}    — nodo previo en el camino óptimo.
  0 si no hay predecesor (o no alcanzable).

# Complejidad
- Temporal : O((V + E) log V) con min-heap
- Espacial  : O(V + E)

# Precondición
Todos los pesos deben ser ≥ 0. Para grafos con pesos negativos
usar Bellman-Ford."""

function dijkstra(g::Graph, src::Int)
    dist = fill(Inf, g.n)
    prev = fill(0,   g.n)
    dist[src] = 0.0

    pq = MinHeap()
    heap_push!(pq, (0.0, src))
    while !isempty(pq)
        d, u = heap_pop!(pq)
        # Nodo ya procesado con distancia menor (entrada obsoleta)
        d > dist[u] && continue
        for (v, w) in g.adj[u]
            nueva_dist = dist[u] + w
            if nueva_dist < dist[v]
                dist[v] = nueva_dist
                prev[v] = u
                heap_push!(pq, (nueva_dist, v))
            end
        end
    end

    return dist, prev
end
"""reconstruir_camino(prev, src, dst) -> Vector{Int}

Reconstruye el camino más corto de src a dst
a partir del vector prev devuelto por dijkstra.
Retorna un vector vacío si dst no es alcanzable.
"""
function reconstruir_camino(prev::Vector{Int}, src::Int, dst::Int)::Vector{Int}
    camino = Int[]
    node = dst
    while node != 0
        pushfirst!(camino, node)
        node == src && return camino
        node = prev[node]
    end
    return Int[]   # no alcanzable
end
# ---------- Casos de prueba ------------------------------

function run_tests()
    println("=" ^ 60)
    println("PRUEBAS: Algoritmo de Dijkstra en Julia")
    println("=" ^ 60)

    # ---- Test 1: Grafo sencillo (no dirigido) -----------
    println("\n[ Test 1 ] Grafo no dirigido con 5 nodos")
    println("  Fuente: nodo 1")
    g1 = Graph(5)
    add_undirected_edge!(g1, 1, 2, 4.0)
    add_undirected_edge!(g1, 1, 3, 2.0)
    add_undirected_edge!(g1, 3, 2, 1.0)
    add_undirected_edge!(g1, 2, 4, 5.0)
    add_undirected_edge!(g1, 3, 5, 8.0)
    add_undirected_edge!(g1, 4, 5, 2.0)

    dist1, prev1 = dijkstra(g1, 1)
    for v in 1:g1.n
        camino = reconstruir_camino(prev1, 1, v)
        println("  1 a $v : dist=$(dist1[v])  camino=$camino")
    end
    @assert dist1[4] == 8.0 "Test 1 falló: 1 a 4 debería ser 8.0"
    @assert dist1[5] == 10.0 "Test 1 falló: 1 a 5 debería ser 10.0"
    println("Test 1 pasó")

    # ---- Test 2: Grafo dirigido --------------------------
    println("\n[ Test 2 ] Grafo dirigido con 4 nodos (estilo red de rutas)")
    println("  Fuente: nodo 1")
    g2 = Graph(4)
    add_edge!(g2, 1, 2, 1.0)
    add_edge!(g2, 1, 3, 4.0)
    add_edge!(g2, 2, 3, 2.0)
    add_edge!(g2, 2, 4, 5.0)
    add_edge!(g2, 3, 4, 1.0)

    dist2, prev2 = dijkstra(g2, 1)
    for v in 1:g2.n
        camino = reconstruir_camino(prev2, 1, v)
        println("  1 a $v : dist=$(dist2[v])  camino=$camino")
    end
    @assert dist2[4] == 4.0 "Test 2 falló: 1 a 4 debería ser 4.0"
    println("Test 2 pasó")

    # ---- Test 3: Nodo aislado (caso borde) --------------
    println("\n[ Test 3 ] Caso borde: nodo aislado (no alcanzable)")
    g3 = Graph(3)
    add_undirected_edge!(g3, 1, 2, 3.0)
    # nodo 3 no tiene aristas

    dist3, _ = dijkstra(g3, 1)
    println("  dist[1 a 1]=$(dist3[1])  dist[1 a 2]=$(dist3[2])  dist[1 a 3]=$(dist3[3])")
    @assert dist3[3] == Inf "Test 3 falló: nodo 3 debería ser Inf"
    println("Test 3 pasó (Inf correcto para nodo aislado)")

    # ---- Test 4: Grafo con arista de peso 0 (caso borde) -
    println("\n[ Test 4 ] Caso borde: arista con peso 0.0")
    g4 = Graph(3)
    add_undirected_edge!(g4, 1, 2, 0.0)
    add_undirected_edge!(g4, 2, 3, 5.0)

    dist4, _ = dijkstra(g4, 1)
    println("  dist[1 a 2]=$(dist4[2])  dist[1 a 3]=$(dist4[3])")
    @assert dist4[2] == 0.0 "Test 4 falló: peso 0 no manejado"
    println("Test 4 pasó")

    # ---- Test 5: Grafo grande aleatorio (stress test) ---
    println("\n[ Test 5 ] Stress test: grafo con 100 nodos, 400 aristas")
    n5 = 100
    g5 = Graph(n5)
    rng_seed = 42
    # Generamos una cadena garantizando conectividad
    for i in 1:(n5-1)
        w = Float64((i * 7 + 3) % 20 + 1)
        add_undirected_edge!(g5, i, i+1, w)
    end
    # Aristas adicionales aleatorias deterministas
    for i in 1:300
        u = (i * 13 + 5) % n5 + 1
        v = (i * 17 + 11) % n5 + 1
        u != v && add_undirected_edge!(g5, u, v, Float64((i * 3 + 7) % 50 + 1))
    end
    dist5, _ = dijkstra(g5, 1)
    alcanzables = count(d -> d < Inf, dist5)
    println("  Nodos alcanzables desde 1: $alcanzables / $n5")
    @assert alcanzables == n5 "Test 5 falló: no todos los nodos son alcanzables"
    println("Test 5 pasó")

    println("\n" * "=" ^ 60)
    println("  Todos los tests pasaron exitosamente")
    println("=" ^ 60)
end

run_tests()