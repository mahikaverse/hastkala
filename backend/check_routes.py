import sys
sys.path.insert(0, '.')

try:
    from app.main import app
    from fastapi.routing import APIRoute, APIRouter
    
    def print_routes(routes, prefix=''):
        for route in routes:
            rtype = type(route).__name__
            rpath = getattr(route, 'path', 'N/A')
            methods = getattr(route, 'methods', set())
            print(f'{prefix}{rtype}: {rpath} {methods}')
            # Check for sub-routes
            if hasattr(route, 'routes'):
                print_routes(route.routes, prefix + '  ')
    
    print_routes(app.routes)
    print('--- DONE ---')
except Exception as e:
    print(f'ERROR: {e}')
    import traceback
    traceback.print_exc()
