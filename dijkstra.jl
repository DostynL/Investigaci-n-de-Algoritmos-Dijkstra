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
    push!(h.data, item)_sift_up!(h, length(h.data))
end

function heap_pop!(h::MinHeap)::Tuple{Float64,Int}
    isempty(h.data) && error("Heap vacío")
    result = h.data[1]
    h.data[1] = h.data[end]
    pop!(h.data) isempty(h.data) || _sift_down!(h, 1)
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
"""function reconstruir_camino(prev::Vector{Int}, src::Int, dst::Int)::Vector{Int}
    camino = Int[]
    node = dst
    while node != 0
        pushfirst!(camino, node)
        node == src && return camino
        node = prev[node]
    end
    return Int[]   # no alcanzable
end