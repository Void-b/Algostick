import 'package:flutter/material.dart';
import '../animations/bubble_sort_scene.dart';
import '../animations/dfs_maze_scene.dart';

class Algorithm {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget Function() sceneBuilder;
  final String pseudoCode;

  const Algorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.sceneBuilder,
    required this.pseudoCode,
  });
}

final algorithms = [
  Algorithm(
    id: 'bubble-sort',
    name: 'Bubble Sort',
    description: 'A simple sorting algorithm that repeatedly steps through the list',
    icon: Icons.sort,
    sceneBuilder: () => const BubbleSortScene(),
    pseudoCode: '''function bubbleSort(arr):
  n = length(arr)
  for i from 0 to n-1:
    for j from 0 to n-i-1:
      if arr[j] > arr[j+1]:
        swap(arr[j], arr[j+1])
  return arr''',
  ),
  Algorithm(
    id: 'dfs-maze',
    name: 'DFS Maze',
    description: 'Depth-first search algorithm to navigate through a maze',
    icon: Icons.grid_on,
    sceneBuilder: () => const DFSMazeScene(),
    pseudoCode: '''function DFS(maze, start, end):
  stack = [start]
  visited = set()
  
  while stack is not empty:
    current = stack.pop()
    if current == end:
      return success
    
    if current not in visited:
      visited.add(current)
      for neighbor in getNeighbors(current):
        if neighbor not in visited:
          stack.push(neighbor)
          
  return failure''',
  ),
];