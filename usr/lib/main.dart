import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frankenstein Elixir of Life',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1F1F1F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AlchemySolverPage(),
    );
  }
}

class AlchemySolverPage extends StatefulWidget {
  const AlchemySolverPage({super.key});

  @override
  State<AlchemySolverPage> createState() => _AlchemySolverPageState();
}

class _AlchemySolverPageState extends State<AlchemySolverPage> {
  final TextEditingController _recipesController = TextEditingController();
  final TextEditingController _targetPotionController = TextEditingController();
  String _result = '';

  @override
  void initState() {
    super.initState();
    // Set default values from Example 1 for user convenience
    _recipesController.text =
        "awakening=snakefangs+wolfbane\n"
        "veritaserum=snakefangs+awakening\n"
        "dragontonic=snakefangs+velarin\n"
        "dragontonic=awakening+veritaserum";
    _targetPotionController.text = "dragontonic";
  }

  void _calculateMinimumOrbs() {
    final allRecipes = _recipesController.text.trim();
    final targetPotion = _targetPotionController.text.trim();

    if (allRecipes.isEmpty || targetPotion.isEmpty) {
      setState(() {
        _result = 'Please provide all recipes and a target potion.';
      });
      return;
    }

    final recipesMap = <String, List<List<String>>>{};
    final lines = allRecipes.split('\n').where((line) => line.isNotEmpty);

    try {
      for (final line in lines) {
        final parts = line.split('=');
        if (parts.length != 2) continue;
        final potion = parts[0].trim();
        final ingredients = parts[1].split('+').map((i) => i.trim()).toList();
        
        if (!recipesMap.containsKey(potion)) {
          recipesMap[potion] = [];
        }
        recipesMap[potion]!.add(ingredients);
      }

      final memo = <String, int>{};
      final minOrbs = _solve(targetPotion, recipesMap, memo);

      setState(() {
        if (minOrbs == -1) {
          _result = 'Cannot brew "$targetPotion" with the given recipes.';
        } else {
          _result = 'Minimum magical orbs for $targetPotion: $minOrbs';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error parsing recipes. Please check the format.';
      });
    }
  }

  int _solve(String potion, Map<String, List<List<String>>> recipes, Map<String, int> memo) {
    if (memo.containsKey(potion)) {
      return memo[potion]!;
    }

    if (!recipes.containsKey(potion)) {
      // It's a base ingredient, requires 0 orbs to "create"
      return 0;
    }

    int minCost = -1;

    for (final recipe in recipes[potion]!) {
      int currentCost = recipe.length - 1;
      bool possible = true;
      for (final ingredient in recipe) {
        final ingredientCost = _solve(ingredient, recipes, memo);
        if (ingredientCost == -1) {
          possible = false;
          break;
        }
        currentCost += ingredientCost;
      }
      
      if (possible) {
        if (minCost == -1 || currentCost < minCost) {
          minCost = currentCost;
        }
      }
    }

    memo[potion] = minCost;
    return minCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frankenstein's Alchemy Lab"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter the recipes from your notes, one per line:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _recipesController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'e.g., potion=ingredient1+ingredient2',
                ),
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Which potion do you wish to brew?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _targetPotionController,
                decoration: const InputDecoration(
                  hintText: 'e.g., dragontonic',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateMinimumOrbs,
                child: const Text('Calculate Minimum Orbs'),
              ),
              const SizedBox(height: 24),
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _result,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
