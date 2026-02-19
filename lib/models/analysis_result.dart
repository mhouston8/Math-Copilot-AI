class AnalysisResult {
  final String solution;
  final String explanation;

  const AnalysisResult({
    required this.solution,
    required this.explanation,
  });

  factory AnalysisResult.fromResponse(String response) {
    final solutionMatch = RegExp(
      r'SOLUTION:(.*?)(?=EXPLANATION:|$)',
      dotAll: true,
    ).firstMatch(response);

    final explanationMatch = RegExp(
      r'EXPLANATION:(.*)',
      dotAll: true,
    ).firstMatch(response);

    return AnalysisResult(
      solution: solutionMatch?.group(1)?.trim() ?? response,
      explanation: explanationMatch?.group(1)?.trim() ?? '',
    );
  }
}
