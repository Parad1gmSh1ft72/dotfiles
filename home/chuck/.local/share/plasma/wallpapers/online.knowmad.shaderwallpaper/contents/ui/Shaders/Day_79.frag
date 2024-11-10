// https://www.shadertoy.com/view/tlySDV

// property Image iChannel0: Image { source: "./Shader_Day_79_iChannel0.png" }

#define pmod(p,x) (mod(p,x) - 0.5*x)
#define dmin(a,b) a.x < b.x ? a : b
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define pal(a,b,c,d,e) ((a) + (b)*sin(tau*((c)*(d) + e)))

#define coolPal(a,b) pal(0.5,0.6,vec3(0.97 + sin(iTime*0.02 + p.z*0.04),3.4 + sin(b)*0.2,0.8),0.4 + (a),3.3 + (b))
#define tunnW 0.8

#define mx (10.*iMouse.x/iResolution.x)
#define my (10.*iMouse.y/iResolution.x)

#define pi acos(-1.)
#define tau (2.*pi)


// The Stairs flavour produces n-1 steps of a staircase:
// much less stupid version by paniq
float fOpUnionStairs(float a, float b, float r, float n) {
    float s = r/n;
    float u = b-r;
    return min(min(a,b), 0.5 * (u + a + abs ((mod (u - a + s, 2. * s)) - s)));
}

// We can just call Union since stairs are symmetric.
float fOpIntersectionStairs(float a, float b, float r, float n) {
    return -fOpUnionStairs(-a, -b, r, n);
}

float fOpDifferenceStairs(float a, float b, float r, float n) {
    return -fOpUnionStairs(-a, b, r, n);
}
vec3 glow = vec3(0);
vec3 glowFog = vec3(0);
vec3 glowCol = vec3(0);


float sdSphere(vec3 p, float s){
    return length(p) -s;
}
float sdBox(vec3 p, vec3 r){
    p = abs(p) - r;
    return max(p.x, max(p.y, p.z));
}

vec4 valueNoise(float t){
    return mix(texture(iChannel0, vec2(t)/256.),texture(iChannel0, vec2(t+1.)/256.),smoothstep(0.,1.,fract(t)));
}

vec2 map(vec3 p){
    vec2 d = vec2(10e6);

    p.xy *= rot(p.z*0.3);
    vec3 z = p;
    #define modDist 2.

    vec3 id = floor(p/modDist )- max(sign(vec3(p.x,p.y,p.z)), 0.);
    p -= modDist*0.5;

    p = pmod(p , modDist);

    vec3 q = p;

    q = abs(q);
    q -= modDist*0.5;

    for(int i = 0; i < 3; i++){

        q = abs(q);
        q.x-= 0.1;

        q.xz *= rot(0.25*pi);
        q.yz *= rot(0.25*pi);
    }

    float cube = sdBox(q, vec3(0.5));

    //sph = fOpIntersectionStairs(sph, -length(p.xz) + 0.1,5.,0.1);
    d = dmin(d, vec2(cube, 0.));

    float cubeWalls = cube - 0.06;
    cubeWalls = max(cubeWalls, -sdBox(q, vec3(0.4,0.4,0.6)));
    cubeWalls = max(cubeWalls, -sdBox(q, vec3(0.4,0.6,0.4)));
    cubeWalls = max(cubeWalls, -sdBox(q, vec3(0.6,0.4,0.4)));

    d = dmin(d, vec2(cubeWalls, 2.));



    float ball = sdSphere(abs(p) - vec3(modDist*0.5,0,modDist*0.5),0.1);
    d = dmin(d, vec2(ball, 1.));


    vec4 n = valueNoise(id.x + id.z + iTime);

    vec3 c = pal(0.8,0.9,vec3(0.6,0.2+ abs(sin(z.x*0.5 +iTime*0.3))*0.6,0.5),0.4,3.7 + sin(z.z)*0.1);
    c = max(c, 0.);
    glow += min(exp(-max(ball, 0.)*6.)*4. * pow(n.x,5.)*40.*c, 3.);



    // TUBE

    vec3 pC = vec3(atan(p.x,p.z)/tau,length(p.xz), p.y);

    pC.x = pmod(pC.x, 0.1);

    pC.y -= 1.05;

    pC.y += pow(smoothstep(0.,1.,abs(p.y)*0.8), 1.7)*0.8;

    //pC.y += pow(abs(p.y), 1.2);

    float glowTube = max(abs(pC.x),abs(pC.y)) - 0.01;

    glowTube = max(glowTube, -length(vec3(pC.x*3., pC.y - 0.02, pmod(pC.z, 0.3))) + 0.04);
    //glowTube = max(glowTube, 0.);
    glow += exp(-glowTube*190.)*max(pal(0.4,0.6,vec3(0.,0.5,0.7),0.8,0.7 + sin(p.z)), 0.)*3.;

    d = dmin(d,vec2(glowTube + 0.02, 0.));


    d.x *= 0.5;
    return d;
}

float N;
vec2 march(vec3 ro, vec3 rd,inout vec3 p,inout float t,inout bool hit){
    vec2 d = vec2(10e6);
    t = 0.; hit = false; p = ro;


    float a = mix(0.8,1.,N); // remove banding from glow

    for(int i = 0; i < 150; i++){
        d = map(p)*a;
        glowFog += exp(-d.x*50.);
        if(d.x < 0.001 || t > 10.){
            hit = true;
            break;
        }
        t += d.x;
        p = ro + rd*t;
    }


    return d;
}
vec3 getRd(vec3 ro, vec3 lookAt, vec2 uv){
    vec3 dir = normalize(lookAt - ro);
    vec3 right = cross(vec3(0,1,0), dir);
    vec3 up = cross(dir, right);
    float fov = 1. + sin(iTime)*0.;
    return normalize(dir + right*uv.x*fov + up*uv.y*fov);
}
vec3 getNormal(vec3 p){
    vec2 t = vec2(0.001, 0.);
    return normalize(map(p).x - vec3(
        map(p-t.xyy).x,
        map(p-t.yxy).x,
        map(p-t.yyx).x
    ));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5*iResolution.xy)/iResolution.y;
    N = texture(iChannel0,(uv)*256.).x*1.;
    uv *= 1. + dot(uv,uv)*0.25;
    vec3 col = vec3(0);

    vec3 ro = vec3(0);

    vec3 lookAt = vec3(0);

    ro.z += iTime*1.;
    lookAt.z = ro.z + 2.;

    ro.xz += vec2(
        sin(iTime),
        cos(iTime)
    )*0.1;



    vec3 rd = getRd(ro, lookAt, uv);

    //rd.xz *= rot(sin(0.5*pi*(floor(iTime*0.125) + pow(smoothstep(0.,1.,fract(iTime*0.125)), 2.5))));
    float t; bool hit; vec3 p;

    vec2 d = march(ro, rd, p, t, hit);


    if (hit){
        vec3 n = getNormal(p);

        vec3 ld = normalize(vec3(1));

        //col += 0.7 + n;
        float diff = max(dot(ro,ld), 0.);
        float fres = pow(1. - max(dot(n,-rd), 0.), 5.);
        float spec = pow(max(dot(n, normalize(ld - rd)), 0.), 20.);

            float ao = clamp(map(p + n*0.5).x/0.5,0.,1.);
        if(d.y == 2.){
            col += min(diff*fres, 1.)*0.5*vec3(0.2,0.2,0.4);

        }
        if(d.y == 0.){
            col += min(diff*fres, 1.)*0.4*vec3(0.4,0.3,0.62) + spec*vec3(0.4,0.,0.2)*0.1;

        }

        col *= ao*0.5 + 0.25;
    }

    col += glow*0.01;

    col = mix(col, vec3(0.3,0.,0.6)*0.1, smoothstep(0.,1., t*0.12));
    col += vec3(0.3,0.,0.1)*0.01*smoothstep(0.,1., t*0.12)*glowFog;
    col = max(col, 0.);
    col = col*0. + smoothstep(0.,1.,col)*0.8;
    col = pow(col, vec3(0.4545 + dot(uv,uv)*0.15));


    fragColor = vec4(col,1.0);
}
