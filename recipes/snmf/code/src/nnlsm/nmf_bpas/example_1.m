% ------------------------------ Usage examples ------------------------------
m = 300;
n = 200;
k = 10;

A = rand(m,n);

% Uncomment only one -------------------------------------------------------------------------
[W,H,iter,HIS]=nmf(A,k);
% [W,H,iter,HIS]=nmf(A,k,'verbose',2);
% [W,H,iter,HIS]=nmf(A,k,'verbose',1,'nnls_solver','as');
% [W,H,iter,HIS]=nmf(A,k,'verbose',1,'type','sparse');
% [W,H,iter,HIS]=nmf(A,k,'verbose',1,'type','sparse','nnls_solver','bp','alpha',1.1,'beta',1.3);
% [W,H,iter,HIS]=nmf(A,k,'verbose',2,'type','plain','w_init',rand(m,k));

