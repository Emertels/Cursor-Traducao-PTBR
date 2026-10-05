!function(){try{var e="undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:{},n=(new e.Error).stack;n&&(e._sentryDebugIds=e._sentryDebugIds||{},e._sentryDebugIds[n]="e8aff597-57e3-5672-9873-38c2f7b5e7e6")}catch(e){}}();
import { translateProps } from "./cursor-pt-dict.js";
import{require_react as t}from"../chunk-3D5M5TPY.js";const e=t();
const _origCreateElement=e.createElement;
const _hookedCreateElement=function(tag,props,...children){
  try{if(props)props=translateProps(props)}catch(err){}
  return _origCreateElement.call(this,tag,props,...children);
};
export const Children=e.Children,Component=e.Component,Fragment=e.Fragment,Profiler=e.Profiler,PureComponent=e.PureComponent,StrictMode=e.StrictMode,Suspense=e.Suspense,SuspenseList=e.SuspenseList,cloneElement=e.cloneElement,createContext=e.createContext,createElement=_hookedCreateElement,createFactory=e.createFactory,createRef=e.createRef,forwardRef=e.forwardRef,isValidElement=e.isValidElement,lazy=e.lazy,memo=e.memo,startTransition=e.startTransition,use=e.use,useActionState=e.useActionState,useCallback=e.useCallback,useContext=e.useContext,useDebugValue=e.useDebugValue,useDeferredValue=e.useDeferredValue,useEffect=e.useEffect,useEffectEvent=e.useEffectEvent,useId=e.useId,useImperativeHandle=e.useImperativeHandle,useInsertionEffect=e.useInsertionEffect,useLayoutEffect=e.useLayoutEffect,useMemo=e.useMemo,useOptimistic=e.useOptimistic,useReducer=e.useReducer,useRef=e.useRef,useState=e.useState,useSyncExternalStore=e.useSyncExternalStore,useTransition=e.useTransition,version=e.version;export default e;
