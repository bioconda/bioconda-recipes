function [ Z,iter ] = solveNormalEqComb( AtA,AtB,PassSet )
% Solve normal equations using combinatorial grouping.
% Although this function was originally adopted from the code of
% "M. H. Van Benthem and M. R. Keenan, J. Chemometrics 2004; 18: 441-450",
% important modifications were made to fix bugs.
%
% Modified by Jingu Kim (jingu@cc.gatech.edu)
%             School of Computational Science and Engineering,
%             Georgia Institute of Technology
%
% Last updated Aug-12-2009

    iter = 0;
    if (nargin ==2) || isempty(PassSet) || all(PassSet(:))
        Z = AtA\AtB;
        iter = iter + 1;
    else
        Z = zeros(size(AtB));
        [n,k1] = size(PassSet);

        %% Fixed on Aug-12-2009
        if k1==1
            Z(PassSet)=AtA(PassSet,PassSet)\AtB(PassSet); 
        else

	    % Column grouping part		

            %% Fixed on Aug-12-2009
            % The following bug was identified by investigating a bug report by Hanseung Lee.
            [sortedPassSet,sortIx] = sortrows(PassSet'); 	% sorts the rows of the matrix X in 
            % ascending order as a group
			% sortedPassSet = PassSet'(sortIx)
            breaks = any(diff(sortedPassSet)');		% Difference and approximate derivative
			% For matrices, ANY(X) operates on the columns of X, returning a row 
			% vector of logical 1's and 0's
            breakIx = [0 find(breaks) k1];
			% breakIx seem to be how to group in blocks

            % codedPassSet = 2.^(n-1:-1:0)*PassSet;
            % [sortedPassSet,sortIx] = sort(codedPassSet);
            % breaks = diff(sortedPassSet);
            % breakIx = [0 find(breaks) k1];

            
	    % solve for each group
            for k=1:length(breakIx)-1
                cols = sortIx(breakIx(k)+1:breakIx(k+1));
                vars = PassSet(:,sortIx(breakIx(k)+1));
                Z(vars,cols) = AtA(vars,vars)\AtB(vars,cols);
                iter = iter + 1;
            end
        end
    end

end
