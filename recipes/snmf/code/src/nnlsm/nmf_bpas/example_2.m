% ------------------------------ Reconstruction test ------------------------------
m = 300;
n = 200;
k = 10;

W_org = rand(m,k);, W_org(rand(m,k)>0.5)=0;
H_org = rand(k,n);, H_org(rand(k,n)>0.5)=0;

% normalize W, since 'nmf' normalizes W before return
norm2=sqrt(sum(W_org.^2,1));
toNormalize = norm2>0;
W_org(:,toNormalize) = W_org(:,toNormalize)./repmat(norm2(toNormalize),m,1);

A = W_org * H_org;

[W,H,iter,HIS]=nmf(A,k,'type','plain','tol',1e-4);

% -------------------- column reordering before computing difference
reorder = zeros(k,1);
selected = zeros(k,1);
for i=1:k
    for j=1:k
        if ~selected(j), break, end
    end
    minIx = j;
    
    for j=minIx+1:k
        if ~selected(j)
            d1 = norm(W(:,i)-W_org(:,minIx));
            d2 = norm(W(:,i)-W_org(:,j));
            if (d2<d1)
                minIx = j;
            end
        end
    end
    reorder(i) = minIx;
    selected(minIx) = 1;
end

W_org = W_org(:,reorder);
H_org = H_org(reorder,:);
% ---------------------------------------------------------------------    

recovery_error_W = norm(W_org-W)/norm(W_org)
recovery_error_H = norm(H_org-H)/norm(H_org)
