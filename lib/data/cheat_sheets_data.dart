import '../models/cheat_sheet.dart';

const List<CheatSheet> cheatSheetsData = [
  CheatSheet(
    id: 'algebra',
    title: 'Algebra',
    subtitle: 'Equations, expressions, and variables',
    summary:
        'Use algebra to solve for unknowns, simplify expressions, and model relationships.',
    sections: [
      CheatSheetSection(
        title: 'Must-Know Formulas',
        bullets: [
          'Slope-intercept form: y = mx + b',
          'Point-slope form: y - y1 = m(x - x1)',
          'Difference of squares: a^2 - b^2 = (a - b)(a + b)',
          'Quadratic formula: x = (-b +/- sqrt(b^2 - 4ac)) / (2a)',
        ],
      ),
      CheatSheetSection(
        title: 'Key Rules',
        bullets: [
          'Do the same operation to both sides of an equation.',
          'Distribute before combining like terms.',
          'Keep variable terms on one side when solving linear equations.',
        ],
      ),
      CheatSheetSection(
        title: 'Common Mistakes',
        bullets: [
          'Forgetting to distribute a negative sign.',
          'Combining unlike terms (for example x and x^2).',
          'Dropping parentheses too early.',
        ],
      ),
    ],
  ),
  CheatSheet(
    id: 'geometry',
    title: 'Geometry',
    subtitle: 'Shapes, angles, area, and volume',
    summary:
        'Geometry helps you measure shapes and reason about space, angles, and dimensions.',
    sections: [
      CheatSheetSection(
        title: 'Must-Know Formulas',
        bullets: [
          'Triangle area: A = 1/2 bh',
          'Circle area: A = pi r^2',
          'Circle circumference: C = 2 pi r',
          'Pythagorean theorem: a^2 + b^2 = c^2',
        ],
      ),
      CheatSheetSection(
        title: 'Key Rules',
        bullets: [
          'Interior angles of a triangle sum to 180 degrees.',
          'Vertical angles are equal.',
          'Opposite sides of a parallelogram are equal and parallel.',
        ],
      ),
      CheatSheetSection(
        title: 'Common Mistakes',
        bullets: [
          'Mixing up area and perimeter formulas.',
          'Using diameter when the formula needs radius.',
          'Forgetting to square units for area.',
        ],
      ),
    ],
  ),
  CheatSheet(
    id: 'trigonometry',
    title: 'Trigonometry',
    subtitle: 'Right triangles and trig functions',
    summary:
        'Trigonometry connects angles and side lengths using sine, cosine, and tangent.',
    sections: [
      CheatSheetSection(
        title: 'Must-Know Formulas',
        bullets: [
          'sin(theta) = opposite / hypotenuse',
          'cos(theta) = adjacent / hypotenuse',
          'tan(theta) = opposite / adjacent',
          'Identity: sin^2(theta) + cos^2(theta) = 1',
        ],
      ),
      CheatSheetSection(
        title: 'Key Rules',
        bullets: [
          'Use inverse trig to find missing angles.',
          'Convert degrees/radians when required by the problem.',
          'Check calculator mode (degree vs radian).',
        ],
      ),
      CheatSheetSection(
        title: 'Common Mistakes',
        bullets: [
          'Using the wrong trig ratio for known sides.',
          'Forgetting calculator mode setting.',
          'Rounding too early in multi-step problems.',
        ],
      ),
    ],
  ),
  CheatSheet(
    id: 'calculus',
    title: 'Calculus',
    subtitle: 'Limits, derivatives, and integrals',
    summary:
        'Calculus studies change and accumulation through derivatives and integrals.',
    sections: [
      CheatSheetSection(
        title: 'Must-Know Formulas',
        bullets: [
          'Power rule: d/dx (x^n) = n x^(n-1)',
          'Constant multiple: d/dx [c f(x)] = c f\'(x)',
          'Product rule: (fg)\' = f\'g + fg\'',
          'Fundamental theorem: integral from a to b f\'(x) dx = f(b) - f(a)',
        ],
      ),
      CheatSheetSection(
        title: 'Key Rules',
        bullets: [
          'Derivatives measure instantaneous rate of change.',
          'Integrals represent accumulated area/change.',
          'Use chain rule when a function is nested.',
        ],
      ),
      CheatSheetSection(
        title: 'Common Mistakes',
        bullets: [
          'Forgetting chain rule in composite functions.',
          'Dropping + C for indefinite integrals.',
          'Sign errors when applying product/quotient rules.',
        ],
      ),
    ],
  ),
];
