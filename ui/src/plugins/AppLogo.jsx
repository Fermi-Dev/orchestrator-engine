import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import { cleanDuplicateSlash } from "./fetch";

const useStyles = makeStyles((theme) => ({
  logo: {
    height: 37,
    width: 175,
    marginRight: 30,
  },
}));

export default function AppLogo() {
  const classes = useStyles();
  const logoPath = 'https://fermi-assets.s3.ap-south-1.amazonaws.com/logo.pngg';
  return <img src={cleanDuplicateSlash(logoPath)} alt="Conductor" className={classes.logo} />;
}
