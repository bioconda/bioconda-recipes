% Nonnegativity Constrained Least Squares with Multiple Righthand Sides 
%      using Block Principal Pivoting method
%
% This software solves the following problem: given A and B, find X such that
%              minimize || AX-B ||_F^2 where X>=0 elementwise.
%
% Reference:
%      Jingu Kim and Haesun Park, Toward Faster Nonnegative Matrix Factorization: A New Algorithm and Comparisons,
%      In Proceedings of the 2008 Eighth IEEE International Conference on Data Mining (ICDM'08), 353-362, 2008
%
% Written by Jingu Kim (jingu@cc.gatech.edu)
% Copyright 2008-2009 by Jingu Kim and Haesun Park, 
%                        School of Computational Science and Engineering,
%                        Georgia Institute of Technology
%
% Check updated code at http://www.cc.gatech.edu/~jingu
% Please send bug reports, comments, or questions to Jingu Kim.
% This code comes with no guarantee or warranty of any kind. Note that this algorithm assumes that the
%      input matrix A has full column rank.
%
% Last modified Feb-20-2009
%
% <Inputs>
%        A : input matrix (m x n) (by default), or A'*A (n x n) if isInputProd==1
%        B : input matrix (m x k) (by default), or A'*B (n x k) if isInputProd==1
%        isInputProd : (optional, default:0) if turned on, use (A'*A,A'*B) as input instead of (A,B)
%        init : (optional) initial value for X
% <Outputs>
%        X : the solution (n x k)
%        Y : A'*A*X - A'*B where X is the solution (n x k)
%        iter : number of iterations
%        success : 1 for success, 0 for failure.
%                  Failure could only happen on a numericall very ill-conditioned problem.

function [ X,Y,iter,success ] = nnlsm_blockpivot( A, B, isInputProd, init )
    if nargin<3, isInputProd=0;, end

    							% 1.
    if isInputProd
        AtA = A; AtB = B;
    else
        AtA = A'*A;, AtB = A'*B;
    end
    
    [n,k]=size(AtB);
    MAX_ITER = n*5;
    % set initial feasible solution     		2.
    X = zeros(n,k);
    if nargin<4
        Y = - AtB;
        PassiveSet = false(n,k);			% F
        iter = 0;
    else
        PassiveSet = (init > 0);			% F
        [ X,iter ] = solveNormalEqComb(AtA,AtB,PassiveSet); % 3.
        Y = AtA * X - AtB;
    end
    
    % parameters
    pbar = 3;
    P = zeros(1,k);, P(:) = pbar;			% Alpha
    Ninf = zeros(1,k);, Ninf(:) = n+1;			% beta
    iter = 0;

   % X(2,825)
    
    NonOptSet = (Y < 0) & ~PassiveSet;			% part 2 V
    InfeaSet = (X < 0) & PassiveSet;			% part 1 V
    NotGood = sum(NonOptSet)+sum(InfeaSet);
    NotOptCols = NotGood > 0;				% I
    
   bigIter = 0;, success=1;
    while(~isempty(find(NotOptCols)))
        bigIter = bigIter+1;
        if ((MAX_ITER >0) && (bigIter > MAX_ITER))   % set max_iter for ill-conditioned (numerically unstable) case
            success = 0;, break
        end

        Cols1 = NotOptCols & (NotGood < Ninf);			% 7. condition
        Cols2 = NotOptCols & (NotGood >= Ninf) & (P >= 1);	% 8. condition
        Cols3Ix = find(NotOptCols & ~Cols1 & ~Cols2);		% 9. condition
        if ~isempty(find(Cols1))
            P(Cols1) = pbar;,Ninf(Cols1) = NotGood(Cols1);	% application of 7.
            PassiveSet(NonOptSet & repmat(Cols1,n,1)) = true;
            PassiveSet(InfeaSet & repmat(Cols1,n,1)) = false;
        end
        if ~isempty(find(Cols2))				% application of 8.
            P(Cols2) = P(Cols2)-1;
            PassiveSet(NonOptSet & repmat(Cols2,n,1)) = true;
            PassiveSet(InfeaSet & repmat(Cols2,n,1)) = false;
        end
        if ~isempty(Cols3Ix)					% application of 9.
            for i=1:length(Cols3Ix)
                Ix = Cols3Ix(i);
                toChange = max(find( NonOptSet(:,Ix)|InfeaSet(:,Ix) ));
                if PassiveSet(toChange,Ix)
                    PassiveSet(toChange,Ix)=false;
                else
                    PassiveSet(toChange,Ix)=true;
                end
            end
        end
        NotOptMask = repmat(NotOptCols,n,1);
        %PassiveSet
        %if (bigiter == 4)
        %    stop
        %end
        
       	% update X and Y

        [ X(:,NotOptCols),subiter ] = solveNormalEqComb(AtA,AtB(:,NotOptCols),PassiveSet(:,NotOptCols));        
           %if (sum(NotOptCols) == 82)
           %AtA 
           %plop = AtB(:,NotOptCols)
           %save AtB.txt plop -ASCII
           %PassiveSet(:,NotOptCols)
           % stop
        %end
        
        iter = iter + subiter;
        X(abs(X)<1e-12) = 0;  % for numerical stability
        %X(2,825)
        Y(:,NotOptCols) = AtA * X(:,NotOptCols) - AtB(:,NotOptCols);
        Y(abs(Y)<1e-12) = 0;            % for numerical stability
        
        % check optimality
        NonOptSet = NotOptMask & (Y < 0) & ~PassiveSet; 	
        InfeaSet = NotOptMask & (X < 0) & PassiveSet;
        NotGood = sum(NonOptSet)+sum(InfeaSet);
        NotOptCols = NotGood > 0;			% update I
    end
end
