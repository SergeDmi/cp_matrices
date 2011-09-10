function [cpx, cpy, dist] = cpSpline2DClosed(x, y, sp)
%CPSPLINE2DCLOSED  Closest Point function for closed spline in 2D
%   Helper function, see cpEggCurve, cpBeanCurve for examples
%
%   Depends on the spline toolbox
%   Internally, uses cpParamCurve_2D with Newton solves to find cp

  if (nargin <= 3)
    DEBUG = 0;
  end
  % first and second derivatives
  sp1 = fnder(sp);
  sp2 = fnder(sp,2);
  %splx = cscvn(pts(:,1)');
  %sply = cscvn(pts(:,1)');

  S1.type='()';
  S1.subs = {1,':'};
  S2.type='()';
  S2.subs = {2,':'};

  % parameterised curve:
  xs = @(t) subsref(ppval(sp,t), S1);
  ys = @(t) subsref(ppval(sp,t), S2);

  % derivative of parametrisation:
  xp = @(t) subsref(ppval(sp1,t), S1);
  yp = @(t) subsref(ppval(sp1,t), S2);

  % second derivative:
  xpp = @(t) subsref(ppval(sp2,t), S1);
  ypp = @(t) subsref(ppval(sp2,t), S2);

  % start and endpts of parameter variable
  endpt1 = sp.breaks(1);
  endpt2 = sp.breaks(end);


  %% now loop and find the CPs
  x1d = x(:); y1d = y(:);

  nx = length(x1d);     % number of points

  cpx = zeros(nx,1);
  cpy = zeros(nx,1);
  dist = zeros(nx,1);
  fail = zeros(nx,1);

  for pt = 1:nx
    [cpx(pt), cpy(pt), dist(pt), fail(pt)] = ...
        cpParamCurve_2D(x1d(pt),y1d(pt), ...
                        xs,ys,xp,yp,xpp,ypp, ...
                        endpt1,endpt2,DEBUG);
  end

  cpx = reshape(cpx, size(x));
  cpy = reshape(cpy, size(x));
  dist = reshape(dist, size(x));
  fail = reshape(fail, size(x));

  if (DEBUG >= 1)
    figure(1);
    plot(cpx(~fail), cpy(~fail), 'bx');
    hold on;
    axis equal;
    plot(x(~~fail), y(~~fail), 'rx');
  end