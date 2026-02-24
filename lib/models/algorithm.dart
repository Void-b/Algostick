import 'package:flutter/material.dart';
import '../animations/bubble_sort_scene.dart';
import '../animations/dfs_maze_scene.dart';
import '../animations/error_attack_scene.dart';
import '../animations/learning_game_scene.dart';

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
  Algorithm(
    id: 'error-attack',
    name: 'Error Attack',
    description: 'Practice dodging and fixing coding errors in an interactive game',
    icon: Icons.bug_report,
    sceneBuilder: () => const ErrorAttackScene(
      question: 'What is the correct syntax for a for loop in Python?',
      correctSequence: ['for', 'i', 'in', 'range(10):', '    print(i)'],
      userInput: [],
    ),
    pseudoCode: '''function handleError(error):
  if isTypingError(error):
    highlight incorrect syntax
    show correction hint
  else if isLogicError(error):
    explain the logical mistake
    suggest proper approach''',
  ),
  Algorithm(
    id: 'learning-game',
    name: 'Algorithm Adventure',
    description: 'Navigate through coding challenges and defeat bugs in this educational game',
    icon: Icons.sports_esports,
    sceneBuilder: () => const LearningGameScene(
      level: 1,
      problem: 'Solve: What is the time complexity of bubble sort?',
      options: ['O(n)', 'O(n²)', 'O(log n)', 'O(n log n)'],
      correctAnswerIndex: 1,
    ),
    pseudoCode: '''function playLevel(difficulty):
  problem = generateProblem(difficulty)
  while not gameOver:
    handlePlayerMovement()
    checkCollisions()
    if problemSolved:
      increaseScore()
      nextLevel()''',
  ),
];