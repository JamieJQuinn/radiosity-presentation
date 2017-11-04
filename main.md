% Radiosity: Global Illumination in Computer Graphics
% Jamie Quinn

---

How do we go from this...

![](./wireframe.png){#id .class height=500px}

---

... to this?

![](./radiosity.png){#id .class height=500px}

---

<p>
How do we go from vertices
<span class="fragment"> to pixels?</span>
</p>

## The Rendering Process
> The automatic process of generating an image from a 2D or 3D model.

## Example Rendering Algorithms

# Raytracing

---

![](./800px-Ray_trace_diagram.png){#id .class height=500px}

## {data-background-image="./Raytracing_reflection.png"}
## {data-background-image="./BallsRender.png"}

---

### But!

It's slow

. . .

Used in

- Film
- TV
- Preprocessing of games
- Select real time applications

# Rasterisation

## 1. Move Camera {data-background-image="./model_view_orthographic.png" data-background-size=contain}
## 2. Apply Perspective {data-background-image="./model_view.png" data-background-size=contain}
## 3. Rasterise Primitives {data-background-image="./model_view_filled.png" data-background-size=contain}
## 4. Shade {data-background-image="./model_view_shaded.png" data-background-size=contain}

## Shading

. . .

> The process of correctly identifying pixel colour due to light sources

---

### Phong Reflection Model

![](./Phong_components_version_4.png){#id .class height=250px}

. . .

$$
I_{\text{polygon}} = k_a i_a +  \Sigma_{m \in \text{lights}} (k_d(\vec{L}_m \cdot \vec{N})i_{m,d} + k_s(\vec{R}_m \cdot \vec{V})^{\alpha}i_{m,s})
$$

. . .

<p>
This applies to each of the
<span class="fragment" style="color:red"> red</span>
<span class="fragment">, <span style="color:green">green</span></span>
<span class="fragment">and <span style="color:blue">blue</span> channels.</span>
</p>

## But! 

It's not very photorealistic, it can't deal easily with

- Reflections
- Refraction
- Soft shadows

. . .

Used mainly in games and real time applications

. . .

Is the basis for current graphics hardware

# Shading and Illumination

## Direct Illumination

## {data-transition="fade"}

![](./direct_illumination.png){#id .class height=600px}

## {data-transition="fade"}

![](./direct_illumination_arrows.png){#id .class height=600px}

## Global Illumination

## {data-transition="fade-out"}

![](./direct_illumination.png){#id .class height=600px}

## {data-transition="fade"}

![](./global_illumination.png){#id .class height=600px}

## {data-transition="fade-in"}

![](./global_illumination_arrows.png){#id .class height=600px}

---

**Direct Illumination Techniques**

- Rasterisation + Phong model
- Zero bounce raytracing

. . .

**Global Illumination Techniques**

- Raytracing (usually)
- Raycasting
- Radiosity

# Radiosity

## Radiosity

>The light energy emitted per surface area per time

. . .

Made up of

1. Light emitted
2. Light reflected

---

If we know the radiosity of every surface, we have solved the shading problem!

## Radiosity Equation

For a surface patch $i$,

$$
B_i = E_i + r_i \Sigma_j F_{ij} B_j,
$$

. . .

or for the entire scene,

$$
\vec{B} = (\mathbf{I} - \vec{r}\, \mathbf{F})^{-1}\vec{E}
$$

## The Form Factor

> A single number between 0 and 1 describing the spatial relationship between two surfaces

- Is one surface visible from another?
- Are two surfaces very close?
- Are two surfaces relatively large?

---

![](./select_patch2.png){#id .class height=600px}

---

![](./View_factor_two_differential_areas_illustration.svg){#id .class height=300px}

. . .

$$
dF_{1 \to 2} = \frac{\cos \theta_1 \cos \theta_2}{\pi s^2} dA_2
$$

. . .

$$
F_{1 \to 2} = \frac{1}{A_1} \int_{A_1} \int_{A_2} \frac{\cos \theta_1 \cos \theta_2}{\pi s^2} dA_2 dA_1
$$

---

So, a recipe for calculating a scenes radiosity could be

1. Find all pairwise form factors
2. Invert radiosity equation
3. Done!

## But!

This "exact" method is slow.

. . .

Can we find a faster method?

# The Hemicube Approximation

---

**The Nusselt Analog**

![](./Nusselt_analog.svg){#id .class height=350px}

Idea: Project a patch onto a hemisphere around another patch, then down onto the plane of the patch

---

Projecting every patch onto a hemisphere like this

![](./hemisphere_over_patch.png){#id .class height=500px}

---

looks like this

![](./patch_view1.png){#id .class height=500px}

---

In the differential limit, the projection leads to the same form factor integral as earlier

. . .

but

. . .

Make the patches "small enough" and we don't even need to bother with the double integral...

---

## Going further: The Hemicube Approximation

---

![](./hemisphere_over_patch.png){#id .class height=600px}

---

![](./hemicube_over_patch.png){#id .class height=600px}

---

The projection is now an implementation of the rasterisation algorithm seen earlier!

# Rasterising the Form Factor

## Positioning the camera

. . .

Translation: Move the entire world.

. . .

``` cpp
Matrix formHemicubeMVP(const Vec3f& eye, const Vec3f& dir, const Vec3f& up) {
  Matrix translation = formTranslation(eye*-1);
  Matrix view = lookAt(Vec3f(0, 0, 0), dir, up)*translation;
  Matrix projection = formRightAngledProjection(HEMICUBE_NEAR_PLANE, 20.0f);
  return projection*view;
}
```

## Rasterise to a hemicube face

## {data-background-video="./rasterisation.webm" data-background-size=contain}

## But!

. . .

Which patches are in front?

## WRong {data-background-video="./z_wrong_anim.webm" data-background-size=contain}

## Right {data-background-video="./z_right_anim.webm" data-background-size=contain}

## Z-buffer Algorithm

Only if a pixel does not have a closer depth value ($z$-value) do we fill with the current triangle colour.

## Another But!

Which patches are facing the right way?

## Back-Face Culling

If $\vec{N}.\vec{s} > 0$, form factor is zero.

# The Final Form Factor

---

In order to fully approximate the hemisphere, the projected areas are added up with weights

---

![](./topFaceFactors.png){#id .class height=600px}

---

![](./sideFaceFactors.png){#id .class height=600px}

--- 

Note: A single projection produces the form factors between one patch and **every** other patch.

# Caveats

## Memory Intensive
For a virtual scene with $n$ polygons, we require $\mathcal{O}(n^2)$ form factors

. . .

Solution?

## Progressive Refinement

Idea: Forget calculating every form factor at once, do it bit by bit

1. Choose a patch
2. Calculate the form factors between it and every patch
3. Shoot (or gather) the radiosity to (from) every patch
4. Repeat until converged

## Possibly wasteful patch sizes

In certain scenes there should be more detail around shadow edges than in well lit areas.

. . .

Solution?

## substructuring

Idea: Take every patch and dynamically break it down into smaller patches

# Thanks For Listening {data-background-image="./radiosity.png" data-background-size=contain}
