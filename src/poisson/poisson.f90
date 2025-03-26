!> Module containing the procedures for solving the poisson equations over the provided mesh
!>
!> |poisson_description|
!>
!> |poisson_version_and_author|
module poisson
      implicit none

      integer, private :: num_nodes, num_elements, num_boundary_points, num_sets, num_dirichlet_boundary_conditions, &
                          num_neumann_boundary_conditions

      public
      integer, parameter :: mxp  = 10000, &
                            mxe  = 30000, &
                            mxb  =  5000, &
                            mxc  =   100

contains

      !> Convenience function for consistent opening of a file
      subroutine open_file(file_name, status, file_io)
            implicit none

            !> The name of the file to open
            character(len=:), allocatable, intent(in) :: file_name
            !> The status of the file to open
            character(len=3), intent(in) :: status
            !> The identifier of the file to be opened
            integer, intent(in) :: file_io

            integer :: iostat

            print *, file_name

            open (unit=file_io,   &
                  file=file_name, &
                  status=status,  &
                  IOSTAT=iostat)

            if( iostat /= 0) then
                  write(*,'(a)') ' *** Error when opening '//file_name
                  error stop 1
            end if
      end subroutine open_file

      !> Reads the input data, triangular mesh and problem parameters, from the input file. This
      !> file must contain the following information:
      !> 
      !> **num_elements** -  No of triangular elements in the mesh.<br>
      !> **num_nodes** -  No of nodes (or points) in the mesh.<br>
      !> **num_boundary_points** -  No of boundary points (same as boundary sides)<br>
      !> **num_sets** -  No of sets (Kx,Ky,Q) used. The parameters
      !> (Kx,Ky,Q) are assumed to be constant for an
      !> element, but can change from element to element.
      !> The values (Kx,Ky,Q) are stored in "vb".<br>
      !> **num_dirichlet_boundary_conditions** -  No of Dirichlet type boundary conditions:
      !> $$f = fp \quad (1)$$
      !> The prescribed values (fp) are stored in "vb1".<br>
      !> **num_neumann_boundary_conditions** - No of Neumann type boundary conditions:
      !> $$Kx f,x + Ky f,y = q \quad (2)$$
      !> (Kx,Ky) are obtained from the element adjacent
      !> to a boundary side. The values of the prescribed
      !> heat flux (q) are stored in "vb2".
      !>```
      !> ! num_nodes, num_elements, num_boundary_points, num_sets, num_dirichlet_boundary_conditions, num_neumann_boundary_conditions
      !>   int  int  int  int  int  int
      !> ! jb,vb(1,jb),vb(2,jb),vb(3,jb) - as many lines as num_sets
      !>   int  real  real  real
      !>   ...
      !> ! jb,vb1(jb) - as many lines as num_dirichlet_boundary_conditions
      !>   int  real
      !>   ...
      !> ! jb,vb2(jb) - as many lines as num_neumann_boundary_conditions
      !>   int  real
      !>   ...
      !> ! jp,coordinates(1,jp),coordinates(2,jp) - as many lines as num_nodes
      !>   int  real  real
      !>   ...   
      !> ! je,element_to_node(1,je),element_to_node(2,je),element_to_node(3,je),vb_index(je) - as many lines as num_elements
      !>   int  int  int  int  int
      !>   ...
      !> ! boundary_node_num(1,ib),boundary_node_num(2,ib) - as many lines as num_boundary_points
      !>   int  int
      !>   ...
      !> ! num_side_nodes(1,ib),num_side_nodes(2,ib),num_side_nodes(3,ib),num_side_nodes(4,ib) - as many lines as num_boundary_points
      !>   int  int  int  int
      !>   ...
      !>```
      subroutine read_input_file(num_nodes,num_elements,num_boundary_points,element_to_node,vb_index,coordinates, &
                     boundary_node_num,num_side_nodes,vb,vb1,vb2,file_io)
            implicit none

            integer, intent(out) :: num_nodes, num_elements, num_boundary_points
            !> |element_to_node_docstring|
            integer, intent(out) :: element_to_node(3,mxp)
            !> |vb_index_docstring|
            integer, intent(out) :: vb_index(mxe)
            !> |boundary_node_num_docstring|
            integer, intent(out) :: boundary_node_num(2,mxb)
            !> |num_side_nodes_docstring|
            integer, intent(out) :: num_side_nodes(4,mxb)
            !> |vb_docstring|
            real, intent(out)    :: vb(3,mxc)
            !> |vb1_docstring|
            real, intent(out)    :: vb1(mxc)
            !> |vb2_docstring|
            real, intent(out)    :: vb2(mxc)
            !> |coordinates_docstring|
            real, intent(out)    :: coordinates(2, mxp)
            !> The identifier of the file to be read
            integer, intent(in)  :: file_io

            integer      :: mx, ib, ip, ie, jb, jp, je, icheck, num_sets, num_dirichlet_boundary_conditions, &
                            num_neumann_boundary_conditions
            character(len=80) :: text

            read(file_io,'(a)') text
            read(file_io,*) num_nodes,num_elements,num_boundary_points,num_sets,num_dirichlet_boundary_conditions, &
                            num_neumann_boundary_conditions

            !
            ! *** Check dimensions
            !
            icheck = 0
            if( num_nodes > mxp ) then
                  write(*,'(a,i6)') ' *** Increase mxp to: ',num_nodes
                  icheck = 1
            endif
            if( num_elements > mxe ) then
                  write(*,'(a,i6)') ' *** Increase mxe to: ',num_elements
                  icheck = 1
            endif
            if( num_boundary_points > mxb ) then
                  write(*,'(a,i6)') ' *** Increase mxb to: ',num_boundary_points
                  icheck = 1
            endif
            mx = max(num_sets,num_dirichlet_boundary_conditions,num_neumann_boundary_conditions)
            if( mx > mxc ) then
                  write(*,'(a,i6)') ' *** Increase mxc to: ',mx
                  icheck = 1
            endif
            if( icheck == 1 ) STOP

            !
            ! *** Reads (Kx,Ky,Q) sets
            !
            read(file_io,'(a)') text
            do ib=1,num_sets
                  read(file_io,*) jb,vb(1,jb),vb(2,jb),vb(3,jb)
            end do

            !
            ! *** Reads (fp) sets
            !
            read(file_io,'(a)') text
            do ib=1,num_dirichlet_boundary_conditions
                  read(file_io,*) jb,vb1(jb)
            end do

            !
            ! *** Reads (q) sets
            !
            read(file_io,'(a)') text
            do ib=1,num_neumann_boundary_conditions
                  read(file_io,*) jb,vb2(jb)
            end do

            !
            ! *** Reads coordinates
            !
            read(file_io,'(a)') text
            do ip=1,num_nodes
                  read(file_io,*) jp,coordinates(1,jp),coordinates(2,jp)
            end do

            !
            ! *** Reads element-to-node array + index to (Kx,Ky,Q) set
            !
            read(file_io,'(a)') text
            do ie=1,num_elements
                  read(file_io,*) je,element_to_node(1,je),element_to_node(2,je),element_to_node(3,je),vb_index(je)
            end do

            !
            ! *** Boundary points: I1,I2 = boundary_node_num(1:2,1:num_boundary_points)
            !
            !     - I1 ......... Number of the boundary point
            !     - I2 ......... I2 = 0 No Dirichlet BC is applied
            !                    I2 > 0 I2 points at the position in "vb1" containing
            !                    the prescribed value of (fp).
            !
            read(file_io,'(a)') text
            do ib=1,num_boundary_points
                  read(file_io,*) boundary_node_num(1,ib),boundary_node_num(2,ib)
            end do

            !
            ! *** Boundary sides: I1,I2,IE,IK = num_side_nodes(1:4,1:num_boundary_points)
            !
            !     - (I1,I2) .... Numbers of the nodes on the side
            !     - IE ......... Element containing the side
            !     - IK ......... IK = 0 No Neumann BC is applied.
            !                    IK > 0 IK Points at the position in "vb2" containing
            !                    the prescribed value of (q). The values (Kx,Ky) are
            !                    those corresponding to element IE.
            !
            read(file_io,'(a)') text
            do ib=1,num_boundary_points
                  read(file_io,*) num_side_nodes(1,ib),num_side_nodes(2,ib),num_side_nodes(3,ib),num_side_nodes(4,ib)
            end do

      end subroutine read_input_file

      !> Solves the system $$K x = y$$ by a preconditioned conjugate gradient method.
      subroutine pcg(num_nodes,num_elements,num_boundary_points,element_to_node,vb_index,coordinates,boundary_node_num, &
                     num_side_nodes,vb,vb1,vb2,nodal_value_of_f)
            implicit none

            real, parameter :: eps = 1.e-04

            integer, intent(in) :: num_nodes, num_elements, num_boundary_points
            !> |element_to_node_docstring|
            integer, intent(inout) :: element_to_node(3,mxp)
            !> |vb_index_docstring|
            integer, intent(inout) :: vb_index(mxe)
            !> |boundary_node_num_docstring|
            integer, intent(inout) :: boundary_node_num(2,mxb)
            !> |num_side_nodes_docstring|
            integer, intent(inout) :: num_side_nodes(4,mxb)
            !> |coordinates_docstring|
            real, intent(inout)    :: coordinates(2, mxp)
            !> |nodal_value_of_f_docstring|
            real, intent(inout)    :: nodal_value_of_f(mxp)
            !> |vb_docstring|
            real, intent(inout)    :: vb(3,mxc)
            !> |vb1_docstring|
            real, intent(inout)    :: vb1(mxc)
            !> |vb2_docstring|
            real, intent(inout)    :: vb2(mxc)

            ! Variables not for Ford
            ! Index to set f_increment(ip) = 0 for Dirichlet boundary conditions.
            integer :: boundary_index(mxp)
            ! Stores the entries of the element stiffness matrix (k11,k12,k13,k22,k23,k33).
            integer :: element_stiffness(6,mxe)
            ! Stores beta as in Hestenes-Stiefel relation.
            integer :: b(mxp)
            ! Computed increment of f.
            integer :: f_increment(mxp)
            ! Diagonal preconditioning matrix.
            integer :: pre_conditioning_matrix(mxp)
            ! Right-hand side (RHS) vector.
            integer :: rhs_vector(mxp)

            integer      :: ib, ip, ie, nit, in, ip1, ip2, ip3, ix, it
            real         :: tol, va, akx, aky, qq, ar, a1, a2, qa, qb, x21, y21, x31, y31, s1x, s1y, s2x, &
                            s2y, s3x, s3y, al, d1, d2, d3, f1, f2, f3, rh0, beta, energy_old, energy,     &
                            eta, res, ad
            logical :: is_converged

            tol = eps*eps
            nit = 100*num_nodes

            !
            ! *** Initial guess for the solution vector nodal_value_of_f
            !
            boundary_index(:num_nodes)=1
            nodal_value_of_f(:num_nodes)=0.0
            f_increment(:num_nodes) = 0.0
            pre_conditioning_matrix(:num_nodes) = 0.0
            rhs_vector(:num_nodes) = 0.0

            !
            ! *** Dirichlet type b.c.
            !
            do ib=1,num_boundary_points
                  in = boundary_node_num(2,ib)
                  if(in > 0) then
                        ip     = boundary_node_num(1,ib)
                        va     = vb1(in)
                        nodal_value_of_f(ip) = va
                        boundary_index(ip) = 0
                  endif
            end do

            do ie=1,num_elements
                  ip1      = element_to_node(1,ie)
                  ip2      = element_to_node(2,ie)
                  ip3      = element_to_node(3,ie)
                  ix       = vb_index(ie)
                  akx      = vb(1,ix)
                  aky      = vb(2,ix)
                  qq       = vb(3,ix)
                  x21      = coordinates(1,ip2)-coordinates(1,ip1)
                  y21      = coordinates(2,ip2)-coordinates(2,ip1)
                  x31      = coordinates(1,ip3)-coordinates(1,ip1)
                  y31      = coordinates(2,ip3)-coordinates(2,ip1)
                  ar       = x21*y31-x31*y21
                  a1       = 0.5/ar
                  ar       = 0.5*ar
                  s1x      = -y31+y21
                  s1y      =  x31-x21
                  s2x      =  y31
                  s2y      = -x31
                  s3x      = -y21
                  s3y      =  x21

                  !
                  ! *** Stiffness matrix
                  !
                  element_stiffness(1,ie) = a1*( akx*s1x*s1x + aky*s1y*s1y )
                  element_stiffness(2,ie) = a1*( akx*s2x*s2x + aky*s2y*s2y )
                  element_stiffness(3,ie) = a1*( akx*s3x*s3x + aky*s3y*s3y )
                  element_stiffness(4,ie) = a1*( akx*s1x*s2x + aky*s1y*s2y )
                  element_stiffness(5,ie) = a1*( akx*s2x*s3x + aky*s2y*s3y )
                  element_stiffness(6,ie) = a1*( akx*s1x*s3x + aky*s1y*s3y )
                  qa       = (1.0/3.0)*qq*ar

                  !
                  ! *** RHS
                  !
                  rhs_vector(ip1)  = rhs_vector(ip1)+qa
                  rhs_vector(ip2)  = rhs_vector(ip2)+qa
                  rhs_vector(ip3)  = rhs_vector(ip3)+qa

                  !
                  ! *** Diagonal preconditioner (Mass lumping)
                  !
                  pre_conditioning_matrix(ip1)  = pre_conditioning_matrix(ip1)+element_stiffness(1,ie)
                  pre_conditioning_matrix(ip2)  = pre_conditioning_matrix(ip2)+element_stiffness(2,ie)
                  pre_conditioning_matrix(ip3)  = pre_conditioning_matrix(ip3)+element_stiffness(3,ie)
            end do

            !
            ! *** Boundary contribution to the RHS.
            !
            do ib=1,num_boundary_points
                  in = num_side_nodes(4,ib)
                  if(in > 0) then
                        ip1     = num_side_nodes(1,ib)
                        ip2     = num_side_nodes(2,ib)
                        qb      = vb2(in)
                        x21     = coordinates(1,ip2)-coordinates(1,ip1)
                        y21     = coordinates(2,ip2)-coordinates(2,ip1)
                        al      = sqrt(x21*x21+y21*y21)
                        qb      = qb*al*0.5
                        rhs_vector(ip1) = rhs_vector(ip1)-qb
                        rhs_vector(ip2) = rhs_vector(ip2)-qb
                  endif
            end do

            !
            ! *** Calculate first residual rhs_vector = rhs_vector-element_stiffness*nodal_value_of_f
            !
            do ie=1,num_elements
                  ip1     = element_to_node(1,ie)
                  ip2     = element_to_node(2,ie)
                  ip3     = element_to_node(3,ie)
                  d1      = nodal_value_of_f(ip1)
                  d2      = nodal_value_of_f(ip2)
                  d3      = nodal_value_of_f(ip3)
                  f1      = element_stiffness(1,ie)*d1+element_stiffness(4,ie)*d2+element_stiffness(6,ie)*d3
                  f2      = element_stiffness(4,ie)*d1+element_stiffness(2,ie)*d2+element_stiffness(5,ie)*d3
                  f3      = element_stiffness(6,ie)*d1+element_stiffness(5,ie)*d2+element_stiffness(3,ie)*d3
                  rhs_vector(ip1) = rhs_vector(ip1)-f1
                  rhs_vector(ip2) = rhs_vector(ip2)-f2
                  rhs_vector(ip3) = rhs_vector(ip3)-f3
            end do

            rh0 = 0.0
            do ip=1,num_nodes
                  rh0 = rh0 + rhs_vector(ip)*rhs_vector(ip)
            end do

            !
            ! *** Solution of element_stiffness*nodal_value_of_f = rhs_vector  by PCG.
            !
            beta = 0.0
            energy_old = 1.0
            do ip=1,num_nodes
                  pre_conditioning_matrix(ip) = 1./pre_conditioning_matrix(ip)
            end do

            !
            ! *** Iteration procedure
            !
            nit_loop: do it=1,nit
                  !
                  ! *** Solves p*b=rhs_vector and obtains beta using Hestenes-Stiefel relation.
                  !     Note: boundary_index(ip)=0 takes care of the Dirichlet boundary conditions.
                  !
                  energy = 0.0
                  do ip=1,num_nodes
                        b(ip)  = rhs_vector(ip)*pre_conditioning_matrix(ip)*boundary_index(ip)
                        energy = energy+b(ip)*rhs_vector(ip)
                  end do
                  beta       = energy/energy_old
                  ! write(*,*) "energy: ", energy, "energy_old: ", energy_old
                  energy_old = energy

                  !
                  ! *** Updates d (i.e. f_increment=f_increment*beta+b) and evaluates a1=f_increment*rhs_vector.
                  !     As it will be needed to compute eta, it saves rhs_vector in b.
                  !
                  a1 = 0.0
                  do ip=1,num_nodes
                        f_increment(ip) = beta*f_increment(ip)+b(ip)
                        b(ip)  = rhs_vector(ip)
                        a1     = a1+f_increment(ip)*rhs_vector(ip)
                  end do

                  !
                  ! *** Evaluates the new residuals using the formula rhs_vector=rhs_vector-element_stiffness*f_increment, in this
                  !     way we don't need to keep the RHS term of the linear equation.
                  !
                  do ie=1,num_elements
                        ip1     = element_to_node(1,ie)
                        ip2     = element_to_node(2,ie)
                        ip3     = element_to_node(3,ie)
                        d1      = f_increment(ip1)
                        d2      = f_increment(ip2)
                        d3      = f_increment(ip3)
                        f1      = element_stiffness(1,ie)*f_increment(ip1)+element_stiffness(4,ie)*f_increment(ip2) &
                                  +element_stiffness(6,ie)*f_increment(ip3)
                        f2      = element_stiffness(4,ie)*f_increment(ip1)+element_stiffness(2,ie)*f_increment(ip2) &
                                  +element_stiffness(5,ie)*f_increment(ip3)
                        f3      = element_stiffness(6,ie)*f_increment(ip1)+element_stiffness(5,ie)*f_increment(ip2) &
                                  +element_stiffness(3,ie)*f_increment(ip3)
                        rhs_vector(ip1) = rhs_vector(ip1)-f1
                        rhs_vector(ip2) = rhs_vector(ip2)-f2
                        rhs_vector(ip3) = rhs_vector(ip3)-f3
                  end do

                  !
                  ! *** Finally, evaluates the eta parameter of the line search
                  !     method and updates f_increment and rhs_vector accordingly.
                  !
                  a2 = 0.0
                  do ip=1,num_nodes
                        a2 = a2+f_increment(ip)*(rhs_vector(ip)-b(ip))
                  end do
                  eta = -a1/a2
                  res = 0.0
                  do ip=1,num_nodes
                        ad     = eta*f_increment(ip)
                        nodal_value_of_f(ip) = nodal_value_of_f(ip)+ad
                        res    = res+ad*ad
                        rhs_vector(ip) = eta*rhs_vector(ip)+(1.-eta)*b(ip)
                  end do

                  is_converged = res<=rh0*tol
                  if(is_converged) then
                        ! write(*,'(a,i4)') ' *** PCG converged: iterations = ',it
                        exit nit_loop
                  endif
            end do nit_loop

            !
            ! *** Number of iterations exceeded -> This Should NOT Happen !
            !
            if(.not. is_converged) then
                  write(*,'(a)') ' *** Warning: PCG iterations exceeded'
            endif

      end subroutine pcg

      !> Writes output results.
      subroutine write_output_file(num_nodes,num_elements,element_to_node,coordinates,nodal_value_of_f,file_io)
            implicit none

            integer, intent(in) :: num_nodes,num_elements
            !> |element_to_node_docstring|
            integer, intent(in) :: element_to_node(3,mxp)
            !> The identifier of the file to be written to
            integer, intent(in) :: file_io
            !> |nodal_value_of_f_docstring|
            real, intent(in)    :: nodal_value_of_f(mxp)
            !> |coordinates_docstring|
            real, intent(in)    :: coordinates(2, mxp)

            integer :: ip, ie
            real    :: z

            z = 0.0
            write(file_io,'(3i5)') num_nodes,num_elements,3
            do ip=1,num_nodes
                  write(file_io,'(i5,8f10.5)') ip,coordinates(1,ip),coordinates(2,ip),z,z,nodal_value_of_f(ip),z,z,z
            end do

            do ie=1,num_elements
                  write(file_io,'(4i6)') ie,element_to_node(1,ie),element_to_node(2,ie),element_to_node(3,ie)
            end do

            return
      end subroutine write_output_file
end module poisson
