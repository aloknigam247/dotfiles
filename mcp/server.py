import ast
import math
import operator

from mcp.server.fastmcp import FastMCP
from mcp.server.fastmcp.exceptions import ToolError

mcp = FastMCP("native-tools")

SAFE_OPS: dict = {
    ast.Add: operator.add,
    ast.BitAnd: operator.and_,
    ast.BitOr: operator.or_,
    ast.BitXor: operator.xor,
    ast.Div: operator.truediv,
    ast.FloorDiv: operator.floordiv,
    ast.Invert: operator.invert,
    ast.LShift: operator.lshift,
    ast.Mod: operator.mod,
    ast.Mult: operator.mul,
    ast.Pow: operator.pow,
    ast.RShift: operator.rshift,
    ast.Sub: operator.sub,
    ast.UAdd: operator.pos,
    ast.USub: operator.neg,
}

SAFE_FUNCS: dict[str, callable] = {
    "abs": abs,
    "ceil": math.ceil,
    "cos": math.cos,
    "exp": math.exp,
    "factorial": math.factorial,
    "floor": math.floor,
    "log": math.log,
    "log10": math.log10,
    "log2": math.log2,
    "round": round,
    "sin": math.sin,
    "sqrt": math.sqrt,
    "tan": math.tan,
}

SAFE_CONSTANTS: dict[str, float] = {
    "e": math.e,
    "pi": math.pi,
    "tau": math.tau,
}


def _eval_node(node: ast.AST) -> float | int:
    match node:
        case ast.Expression(body=body):
            return _eval_node(body)
        case ast.Constant(value=v) if isinstance(v, (int, float)):
            return v
        case ast.UnaryOp(op=op, operand=operand) if type(op) in SAFE_OPS:
            return SAFE_OPS[type(op)](_eval_node(operand))
        case ast.BinOp(left=left, op=op, right=right) if type(op) in SAFE_OPS:
            return SAFE_OPS[type(op)](_eval_node(left), _eval_node(right))
        case ast.Call(func=ast.Name(id=name), args=args, keywords=[]) if name in SAFE_FUNCS:
            return SAFE_FUNCS[name](*(_eval_node(a) for a in args))
        case ast.Name(id=name) if name in SAFE_CONSTANTS:
            return SAFE_CONSTANTS[name]
        case _:
            raise ToolError(f"Unsupported expression: {ast.dump(node)}")


@mcp.tool()
async def calculator(expression: str) -> str:
    """Evaluate a math expression and return the result.

    Supports: +, -, *, /, //, %, **, bitwise ops, and functions
    (abs, ceil, cos, exp, factorial, floor, log, log10, log2, round, sin, sqrt, tan).
    Constants: pi, e, tau.

    Args:
        expression: Math expression to evaluate, e.g. "sqrt(2) * pi" or "2**10 + 1".
    """
    try:
        tree = ast.parse(expression.strip(), mode="eval")
    except SyntaxError as exc:
        raise ToolError(f"Invalid expression: {exc}") from exc

    try:
        result = _eval_node(tree)
    except ToolError:
        raise
    except Exception as exc:
        raise ToolError(f"Evaluation error: {exc}") from exc

    if isinstance(result, float) and result.is_integer():
        result = int(result)
    return str(result)


if __name__ == "__main__":
    mcp.run(transport="stdio")
