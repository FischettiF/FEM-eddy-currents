## -*- texinfo -*-
## @deftypefn {Function File} {[@var{C}]} = @
## reaction_full(@var{mesh},@var{delta},@var{zeta})
##
## Build the finite element full mass matrix for a diffusion
## problem.
##
## The equation taken into account is:
##
## @var{delta} * @var{zeta} * u = f
##
## where @var{delta} is an element-wise constant scalar function, while
## @var{zeta} is a piecewise linear conforming scalar function.
##
## @seealso{bim2a_rhs, bim2a_advection_diffusion, bim2a_laplacian,
## bim1a_reaction, bim3a_reaction}
## @end deftypefn

function C = reaction_full(mesh, delta, zeta)

  ## Check input
  if nargin != 3
    error("reaction_full: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("reaction_full: first input is not a valid mesh structure.");
  endif

  p      = mesh.p;
  t      = mesh.t;
  nnodes = columns(p);
  nelem  = columns(t);

  ## Turn scalar input to a vector of appropriate size
  if isscalar(delta)
    delta  = delta * ones (nelem, 1);
  endif
  if isscalar(zeta)
    zeta = zeta * ones (nnodes, 1);
  endif

  if !( isvector (delta) && isvector (zeta) && (numel (delta) == nelem) && (numel (zeta) == nnodes))
    error("reaction_full: coefficients are vectors of correct size.");
  endif

  ## Local element matrices (one 3x3 matrix for each triangle in the mesh)
  Blocmat = zeros(3, 3, nelem);

  ## To integrate constants over each triangle we need to multiply by
  ## the triangle area. Multiply by the diffusion coefficient now tu
  ## simplify subsequent computations. Use inverse average for the
  ## diffusion coefficient.
  zetadeltaareak = reshape (3./sum (1./zeta(:)(mesh.t (1:3)), 1)(:) .* delta(:) .* mesh.area(:), 1, 1, nelem);
  phi_ij = [2 1 1; 1 2 1; 1 1 2] / 24; % integrals of reference basis functions

  ## Computation
  for inode = 1:3
    for jnode = 1:3
      ginode(inode,jnode,:) = mesh.t(inode,:);
      gjnode(inode,jnode,:) = mesh.t(jnode,:);
      Blocmat(inode, jnode, :) = phi_ij(inode, jnode) .* 2 .* zetadeltaareak;
    endfor
  endfor

  ## Assemble the local (full) matrices into one global (sparse) matrix
  C = sparse (ginode(:), gjnode(:), Blocmat(:));

endfunction

