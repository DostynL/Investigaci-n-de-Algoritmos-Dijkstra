# Algoritmo de Dijkstra — Implementación en Julia

Implementación del algoritmo de Dijkstra para encontrar el camino más corto
desde un nodo origen a todos los demás nodos de un grafo ponderado.

## Requisitos

- [Julia](https://julialang.org/downloads/) versión 1.6 o superior
- No se requieren paquetes externos. La implementación usa únicamente
  la biblioteca estándar de Julia.

## Cómo ejecutar

### 1. Instalar Julia

Descarga Julia desde https://julialang.org/downloads/ e instálalo.
Verifica la instalación con:

```bash
julia --version
```

### 2. Ejecutar los tests

Desde la carpeta del proyecto:

```bash
julia dijkstra.jl
```

Esto ejecutará automáticamente los 5 casos de prueba incluidos y mostrará
los resultados en consola.

### 3. Usar el módulo en tu propio código

```julia
include("dijkstra.jl")

# Crear un grafo con 4 nodos
g = Graph(4)

# Agregar aristas (nodo_origen, nodo_destino, peso)
add_undirected_edge!(g, 1, 2, 3.0)
add_undirected_edge!(g, 1, 3, 1.0)
add_undirected_edge!(g, 3, 4, 2.0)
add_undirected_edge!(g, 2, 4, 1.0)

# Ejecutar Dijkstra desde el nodo 1
dist, prev = dijkstra(g, 1)

# Ver distancias
println(dist)   # [0.0, 3.0, 1.0, 3.0]

# Reconstruir camino de 1 a 4
camino = reconstruir_camino(prev, 1, 4)
println(camino) # [1, 3, 4]
```

## Estructura del proyecto

```
dijkstra/
├── dijkstra.jl   # Implementación principal + tests
└── README.md     # Este archivo
```

## Funciones principales

| Función | Descripción |
|---|---|
| `Graph(n)` | Crea un grafo vacío con `n` nodos |
| `add_edge!(g, u, v, w)` | Agrega arista dirigida u→v con peso w |
| `add_undirected_edge!(g, u, v, w)` | Agrega arista no dirigida |
| `dijkstra(g, src)` | Ejecuta Dijkstra desde `src`, retorna `(dist, prev)` |
| `reconstruir_camino(prev, src, dst)` | Reconstruye el camino óptimo |

## Casos de prueba incluidos

| Test | Descripción |
|---|---|
| Test 1 | Grafo no dirigido de 5 nodos con múltiples caminos |
| Test 2 | Grafo dirigido de 4 nodos |
| Test 3 | Nodo aislado (debe retornar `Inf`) |
| Test 4 | Arista con peso 0 |
| Test 5 | Stress test con 100 nodos y ~400 aristas |

## Notas

- Los nodos se indexan desde **1** (convención Julia).
- El algoritmo **no soporta pesos negativos**. Para grafos con pesos
  negativos, usar Bellman-Ford.
- Complejidad: **O((V + E) log V)** con la implementación de min-heap incluida.
