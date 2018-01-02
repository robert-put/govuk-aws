#
# == Manifest: Project: Security Groups: whitehall-frontend
#
# The whitehall-frontend needs to be accessible on ports:
#   - 443 from the other VMs
#
# === Variables:
# stackname - string
#
# === Outputs:
# sg_whitehall-frontend_id
# sg_whitehall-frontend_elb_id

resource "aws_security_group" "whitehall-frontend" {
  name        = "${var.stackname}_whitehall-frontend_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access to the whitehall-frontend host from its ELB"

  tags {
    Name = "${var.stackname}_whitehall-frontend_access"
  }
}

resource "aws_security_group_rule" "whitehall-frontend_ingress_whitehall-frontend-elb_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = "${aws_security_group.whitehall-frontend.id}"

  # Which security group can use this rule
  source_security_group_id = "${aws_security_group.whitehall-frontend_elb.id}"
}

resource "aws_security_group" "whitehall-frontend_elb" {
  name        = "${var.stackname}_whitehall-frontend_elb_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access the whitehall-frontend ELB"

  tags {
    Name = "${var.stackname}_whitehall-frontend_elb_access"
  }
}

# TODO: Audit
resource "aws_security_group_rule" "whitehall-frontend-elb_ingress_management_443" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.whitehall-frontend_elb.id}"
  source_security_group_id = "${aws_security_group.management.id}"
}

resource "aws_security_group_rule" "whitehall-frontend-elb_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.whitehall-frontend_elb.id}"
}
